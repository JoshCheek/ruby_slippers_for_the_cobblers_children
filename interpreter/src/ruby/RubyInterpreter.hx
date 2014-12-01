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

  public var klassClass  : RClass;
  public var objectClass : RClass;

  // to think about: pass state instead of being void?
  public function new() {
    workToDo            = new List();
    objectSpace         = [];
    _symbols            = new InternalMap();

    // Object / Class
    objectClass                   = new RClass();
    objectClass.name              = "Object";
    objectClass.instanceVariables = new InternalMap();
    objectClass.instanceMethods   = new InternalMap();
    objectClass.constants         = new InternalMap();

    klassClass                    = new RClass();
    klassClass.name               = "Class";
    klassClass.instanceVariables  = new InternalMap();
    klassClass.instanceMethods    = new InternalMap();
    klassClass.superclass         = objectClass;

    klassClass.klass              = klassClass;
    objectClass.klass             = klassClass;
    _toplevelNamespace            = objectClass;

    // main
    var main               = new RObject();
    main.klass             = objectClass;
    main.instanceVariables = new InternalMap();

    // setup stack
    var toplevelBinding               = new RBinding();
    toplevelBinding.klass             = objectClass;
    toplevelBinding.instanceVariables = new InternalMap();
    toplevelBinding.self              = main;
    toplevelBinding.defTarget         = _toplevelNamespace;
    toplevelBinding.localVars         = new InternalMap();

    stack                             = [toplevelBinding];

    // special constants
    rubyNil                     = new RObject();
    rubyNil.klass               = objectClass; // should be NilClass
    rubyNil.instanceVariables   = new InternalMap();

    rubyTrue                    = new RObject();
    rubyTrue.klass              = objectClass; // should be TrueClass
    rubyTrue.instanceVariables  = new InternalMap();

    rubyFalse                   = new RObject();
    rubyFalse.klass             = objectClass; // should be FalseClass
    rubyFalse.instanceVariables = new InternalMap();

    _currentExpression = rubyNil;
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
    if (!_symbols.exists(name)) {
      var symbol               = new RSymbol();
      symbol.klass             = _toplevelNamespace;
      symbol.instanceVariables = new InternalMap();
      symbol.name              = name;
      _symbols.set(name, symbol);
    }
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
          var string               = new RString();
          string.klass             = objectClass;
          string.instanceVariables = new InternalMap();
          string.value             = value;
          return string;
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
            var _klass                  = new RClass();
            klass                       = _klass; // Fuck you
            _klass.name                 = name;
            _klass.klass                = klassClass;
            _klass.instanceVariables    = new InternalMap();
            _klass.instanceMethods      = new InternalMap();
            _klass.constants            = new InternalMap();
            _klass.superclass           = objectClass;
            toplevelNamespace().setConstant(name, klass);
          }
          var binding               = new RBinding();
          binding.klass             = objectClass; // TODO: should be Binding (unless we want these to be internal until asked for, like in MRI)
          binding.instanceVariables = new InternalMap();
          binding.self              = klass;
          binding.defTarget         = cast(klass, RClass);
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

          var binding = new RBinding();
          binding.klass = objectClass;
          binding.instanceVariables = new InternalMap();
          binding.self              = receiver;
          binding.defTarget         = methodBag;
          binding.localVars         = new InternalMap();

          stack.push(binding); // haven't tested defTarget here

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
          var method               = new RMethod();
          method.klass             = objectClass; // TODO WRONG
          method.instanceVariables = new InternalMap();
          method.name              = name;
          method.args              = args;
          method.body              = body;

          currentBinding().defTarget.instanceMethods.set(name, method);
          return rubySymbol(name);
        });
      case node:
        throw "Unrecognized node: " + Std.string(node);
    }
  }
}
