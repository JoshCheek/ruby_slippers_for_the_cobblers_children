package ruby;

import ruby.ds.Ast;
import ruby.ds.InternalMap;
import ruby.ds.objects.*;

using ruby.LanguageGoBag;

class RubyInterpreter {
  private var stack              : Array<RBinding>;
  private var objectSpace        : Array<RObject>;
  private var _currentExpression : RObject;
  private var workToDo           : List<Void -> RObject>;
  private var _toplevelNamespace : RClass;
  private var _symbols           : InternalMap<RSymbol>;
  public  var rubyNil            : RObject;
  public  var rubyTrue           : RObject;
  public  var rubyFalse          : RObject;

  // to think about: pass state instead of being void?
  public function new() {
    workToDo            = new List();
    objectSpace         = [];
    _toplevelNamespace  = new RClass('Object');
    var main            = new RObject(_toplevelNamespace);
    var toplevelBinding = new RBinding(main, _toplevelNamespace);
    stack               = [toplevelBinding];
    _symbols            = new InternalMap();

    rubyNil             = new RObject(_toplevelNamespace); // should be NilClass
    rubyTrue            = new RObject(_toplevelNamespace); // should be TrueClass
    rubyFalse           = new RObject(_toplevelNamespace); // should be FalseClass
    _currentExpression  = rubyNil;
  }

  public function toplevelNamespace():RClass {
    return _toplevelNamespace;
  }

  public function hasWorkLeft():Bool {
    return workToDo.length != 0;
  }

  public function drainAll():Array<RObject> {
    var drained = [];
    while(hasWorkLeft()) drained.push(drain());
    return drained;
  }

  public function currentExpression():RObject {
    return _currentExpression;
  }

  public function currentBinding():RBinding {
    return stack[0]; // FIXME
  }

  public function rubySymbol(name:String):RSymbol {
    if (!_symbols.exists(name))
      _symbols.set(name, new RSymbol(name));
    return _symbols.get(name);
  }

  public function addCode(ast:Dynamic):Void {
    fillFrom(ast);
  }

  // does it make more sense to return a enum that can either be the resulting expression
  // or some value representing a set of work that we are in the middle of, and will ultimately result in an expression
  // e.g. the method lookup algorithm, represented as a value?
  public function drain() {
    var work = workToDo.pop();
    if(work == null)
      throw "Can't drain, b/c there's no work to do (is the AST case handled?)";
    _currentExpression = work();
    return _currentExpression;
  }

  public function fillFrom(ast:Ast) {
    switch(ast) {
      case Expressions(expressions):
        for(expr in expressions.reverseIterator()) {
          fillFrom(expr);
        };
      case String(value):
        workToDo.push(function() {
          return new RString(value);
        });
      case SetLocalVariable(name, value):
        workToDo.push(function() {
          var obj = currentExpression();
          currentBinding().localVars.set(name, obj);
          return obj;
        });
        fillFrom(value);
      case GetLocalVariable(name):
        workToDo.push(function() {
          return currentBinding().localVars.get(name);
        });
      case Class(Constant(Nil, name), superclassAst, body):
        workToDo.push(function() {
          stack.pop();
          return currentExpression();
        });
        fillFrom(body);
        workToDo.push(function() {
          var klass = toplevelNamespace().getConstant(name);
          if(null == klass) {
            klass = new RClass(name);
            toplevelNamespace().setConstant(name, klass);
          }
          stack.push(new RBinding(klass, cast(klass, RClass)));
          return currentExpression(); // FIXME
        });
      case Nil:
        workToDo.push(function() return rubyNil);
      case True:
        workToDo.push(function() return rubyTrue);
      case False:
        workToDo.push(function() return rubyFalse);
      case Send(target, message, argAsts):
        workToDo.push(function() {
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
          stack.push(new RBinding(receiver, methodBag)); // haven't tested defTarget here

          // last thing we will do is pop binding, get return value
          workToDo.push(function() {
            var returnValue = currentExpression();
            stack.pop();
            return returnValue;
          });

          // next thing we will do is evaluate the method
          fillFrom(method.body);

          // maybe switch over to returning an enum instead of an object
          return rubyNil;
        });
      case MethodDefinition(name, args, body):
        workToDo.push(function() {
          currentBinding().defTarget.instanceMethods.set(name, new RMethod(name, args, body));
          return rubySymbol(name);
        });
      case node:
        throw "Unrecognized node: " + Std.string(node);
    }
  }
}
