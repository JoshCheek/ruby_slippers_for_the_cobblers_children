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
      var symbol:RSymbol = {name: name, klass: world.objectClass, ivars: new InternalMap()};
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

  public function hasMethod(methodBag:RClass, name:String):Bool {
    return methodBag.imeths.exists(name);
  }

  public function localsForArgs(meth:RMethod, args:Array<RObject>):InternalMap<RObject> {
    return new InternalMap(); // FIXME
  }

  public function getConstant(namespace:RClass, name:String):RObject {
    return namespace.constants.get(name);
  }

  public function setConstant(namespace:RClass, name:String, object:RObject):RObject {
    namespace.constants.set(name, object);
    return object;
  }

  public function getMethod(methodBag:RClass, methodName:String):RMethod {
    return methodBag.imeths.get(methodName);
  }

  public function fillFrom(ast:Ast) {
    switch(ast) {
      case Expressions(expressions):
        for(expr in expressions.reverseIterator()) {
          fillFrom(expr);
        };
      case String(value):
        fill(function() {
          var string:RString = {value: value, klass: world.objectClass, ivars: new InternalMap()};
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
          var klass = getConstant(toplevelNamespace(), name);
          if(null == klass) {
            var _klass:RClass = {
              name:       name,
              klass:      world.klassClass,
              ivars:      new InternalMap(),
              imeths:     new InternalMap(),
              constants:  new InternalMap(),
              superclass: world.objectClass,
            };
            klass = _klass; // Fuck you
            setConstant(toplevelNamespace(), name, klass);
          }
          var binding = {
            klass:     world.objectClass,
            ivars:     new InternalMap(),
            self:      klass,
            defTarget: klass,
          }
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
          while(methodBag != null && !hasMethod(methodBag, message))
            methodBag = methodBag.superclass;

          if(methodBag == null)
            throw "Could not find the method on " + Std.string(receiver); // eventually handle method_midding and nomethod errror

          var method = getMethod(methodBag, message);

          // put binding onto the stack
          var locals:InternalMap<RObject> = localsForArgs(method, args);

          var binding = {
            klass:     world.objectClass,
            ivars:     new InternalMap(),
            self:      receiver,
            defTarget: methodBag,
            lvars:     new InternalMap(),
          }

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
          var method = {
            klass: world.objectClass,
            ivars: new InternalMap(),
            name:  name,
            args:  args,
            body:  body,
          }

          currentBinding().defTarget.imeths.set(name, method);
          return rubySymbol(name);
        });
      case node:
        throw "Unrecognized node: " + Std.string(node);
    }
  }
}
