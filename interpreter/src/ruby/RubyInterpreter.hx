package ruby;

import ruby.ds.Ast;
import ruby.ds.InternalMap;
import ruby.ds.World;
import ruby.ds.objects.*;

using ruby.LanguageGoBag;
using ruby.WorldDomination;

class RubyInterpreter {
  public var world:World;

  public static function fromBootstrap():RubyInterpreter {
    return new RubyInterpreter(WorldDomination.bootstrap());
  }

  public function new(world:World) {
    this.world = world;
  }

  public function toplevelNamespace():RClass {
    return world.toplevelNamespace;
  }

  public function hasWorkLeft():Bool {
    return world.workToDo.length != 0;
  }

  public function drainAll():Array<RObject> {
    var drained = [];
    while(hasWorkLeft()) drained.push(drain());
    return drained;
  }

  public function currentExpression():RObject {
    return world.currentExpression;
  }

  public function currentBinding():RBinding {
    return world.stack[0]; // FIXME
  }

  public function rubySymbol(name:String):RSymbol {
    if (!world.symbols.exists(name)) {
      var symbol   = new RSymbol();
      symbol.klass = toplevelNamespace();
      symbol.ivars = new InternalMap();
      symbol.name  = name;
      world.symbols.set(name, symbol);
    }
    return world.symbols.get(name);
  }

  public function addCode(ast:Dynamic):Void {
    fillFrom(ast);
  }

  // does it make more sense to return a enum that can either be the resulting expression
  // or some value representing a set of work that we are in the middle of, and will ultimately result in an expression
  // e.g. the method lookup algorithm, represented as a value?
  public function drain() {
    var work = world.workToDo.pop();
    if(work == null)
      throw "Can't drain, b/c there's no work to do (is the AST case handled?)";
    world.currentExpression = work();
    return world.currentExpression;
  }

  public function fill(work:Void->RObject):Void {
    world.workToDo.push(work);
  }

  public function fillFrom(ast:Ast) {
    switch(ast) {
      case Expressions(expressions):
        for(expr in expressions.reverseIterator()) {
          fillFrom(expr);
        };
      case String(value):
        fill(function() {
          var string   = new RString();
          string.klass = world.objectClass;
          string.ivars = new InternalMap();
          string.value = value;
          return string;
        });
      case SetLocalVariable(name, value):
        fill(function() {
          var obj = currentExpression();
          currentBinding().lvars.set(name, obj);
          return obj;
        });
        fillFrom(value);
      case GetLocalVariable(name):
        fill(function() {
          return currentBinding().lvars.get(name);
        });
      case Class(Constant(Nil, name), superclassAst, body):
        fill(function() {
          world.stack.pop();
          return currentExpression();
        });
        fillFrom(body);
        fill(function() {
          var klass = toplevelNamespace().getConstant(name);
          if(null == klass) {
            var _klass                  = new RClass();
            klass                       = _klass; // Fuck you
            _klass.name                 = name;
            _klass.klass                = world.klassClass;
            _klass.ivars                = new InternalMap();
            _klass.instanceMethods      = new InternalMap();
            _klass.constants            = new InternalMap();
            _klass.superclass           = world.objectClass;
            toplevelNamespace().setConstant(name, klass);
          }
          var binding       = new RBinding();
          binding.klass     = world.objectClass; // TODO: should be Binding (unless we want these to be internal until asked for, like in MRI)
          binding.ivars     = new InternalMap();
          binding.self      = klass;
          binding.defTarget = cast(klass, RClass);
          return currentExpression(); // FIXME
        });
      case Nil:
        fill(function() return world.rubyNil);
      case True:
        fill(function() return world.rubyTrue);
      case False:
        fill(function() return world.rubyFalse);
      case Send(target, message, argAsts):
        fill(function() {
          var receiver:RObject;

          // find receiver
          switch(target) {
            case Nil:
              receiver = currentBinding().self;
            case _:
              throw "Handle the case when the receiver is not null";
          }

          // evaluate args
          var args:Array<RObject> = []; // TODO: eval argAsts to get this

          // find method
          var methodBag = receiver.klass;
          while(methodBag != null && !methodBag.hasMethod(message))
            methodBag = methodBag.superclass;

          if(methodBag == null)
            throw "Could not find the method on " + Std.string(receiver); // eventually handle method_midding and nomethod errror

          var method = methodBag.getMethod(message);

          // put binding onto the stack
          var locals:InternalMap<RObject> = method.localsForArgs(args);

          var binding       = new RBinding();
          binding.klass     = world.objectClass;
          binding.ivars     = new InternalMap();
          binding.self      = receiver;
          binding.defTarget = methodBag;
          binding.lvars     = new InternalMap();

          world.stack.push(binding); // haven't tested defTarget here

          // last thing we will do is pop binding, get return value
          fill(function() {
            var returnValue = currentExpression();
            world.stack.pop();
            return returnValue;
          });

          // next thing we will do is evaluate the method
          fillFrom(method.body);

          // maybe switch over to returning an enum instead of an object
          return world.rubyNil;
        });
      case MethodDefinition(name, args, body):
        fill(function() {
          var method   = new RMethod();
          method.klass = world.objectClass; // TODO WRONG
          method.ivars = new InternalMap();
          method.name  = name;
          method.args  = args;
          method.body  = body;

          currentBinding().defTarget.instanceMethods.set(name, method);
          return rubySymbol(name);
        });
      case node:
        throw "Unrecognized node: " + Std.string(node);
    }
  }
}
