package ruby;

class RubyInterpreter {
  private var stack              : Array<RubyBinding>;
  private var objectSpace        : Array<RubyObject>;
  private var _currentExpression : RubyObject;
  private var workToDo           : List<Void -> RubyObject>;
  private var _toplevelNamespace : RubyClass;
  private var _symbols           : haxe.ds.StringMap<RubySymbol>;
  public  var rubyNil            : RubyObject;
  public  var rubyTrue           : RubyObject;
  public  var rubyFalse          : RubyObject;

  // to think about: pass state instead of being void?
  public function new() {
    workToDo            = new List();
    objectSpace         = [];
    _toplevelNamespace  = new RubyClass('Object');
    var main            = new RubyObject(_toplevelNamespace);
    var toplevelBinding = new RubyBinding(main, _toplevelNamespace);
    stack               = [toplevelBinding];
    _symbols            = new haxe.ds.StringMap();

    rubyNil             = new RubyObject(_toplevelNamespace); // should be NilClass
    rubyTrue            = new RubyObject(_toplevelNamespace); // should be TrueClass
    rubyFalse           = new RubyObject(_toplevelNamespace); // should be FalseClass
    _currentExpression  = rubyNil;
  }

  public function rubySymbol(name:String):RubySymbol {
    if (!_symbols.exists(name))
      _symbols.set(name, new RubySymbol(name));
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

  public function fillFrom(ast:RubyAst) {
    switch(ast) {
      case Expressions(expressions):
        for(expr in reverseIterator(expressions)) {
          fillFrom(expr);
        };
      case String(value):
        workToDo.push(function() {
          return new RubyString(value);
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
      case RClass(Constant(Nil, name), superclassAst, body):
        workToDo.push(function() {
          stack.pop();
          return currentExpression();
        });
        fillFrom(body);
        workToDo.push(function() {
          var klass = toplevelNamespace().getConstant(name);
          if(null == klass) {
            klass = new RubyClass(name);
            toplevelNamespace().setConstant(name, klass);
          }
          stack.push(new RubyBinding(klass, cast(klass, RubyClass)));
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
          var receiver:RubyObject;

          // find receiver
          switch(target) {
            case Nil:
              receiver = currentBinding().self;
            case _:
              throw "Handle the case when the receiver is not null";
          }

          // evaluate args
          var args:Array<RubyObject> = []; // TODO: eval argAsts to get this

          // find method
          var methodBag = receiver.klass;
          while(methodBag != null && !methodBag.hasMethod(message))
            methodBag = methodBag.superclass;

          if(methodBag == null)
            throw "Could not find the method on " + Std.string(receiver); // eventually handle method_midding and nomethod errror

          var method = methodBag.getMethod(message);

          // put binding onto the stack
          var locals:haxe.ds.StringMap<RubyObject> = method.localsForArgs(args);
          stack.push(new RubyBinding(receiver, methodBag)); // haven't tested defTarget here

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
          currentBinding().defTarget.instanceMethods.set(name, new RubyMethod(name, args, body));
          return rubySymbol(name);
        });
      case node:
        throw "Unrecognized node: " + Std.string(node);
    }
  }

  public function toplevelNamespace():RubyClass {
    return _toplevelNamespace;
  }

  public function hasWorkLeft():Bool {
    return workToDo.length != 0;
  }

  public function drainAll():Array<RubyObject> {
    var drained = [];
    while(hasWorkLeft()) drained.push(drain());
    return drained;
  }

  public function printedInternally():String {
    return 'THIS SHOULD BE PRINTED INTERNALLY';
  }

  public function lookupClass(name:String):RubyClass {
    return new RubyClass('THIS SHOULD BE A CLASS');
  }

  public function eachObject(userClass:RubyClass):Array<String> {
    return ['THIS SHOULD BE AN ARRAY OF OBJECTS'];
  }

  public function currentExpression():RubyObject {
    return _currentExpression;
  }

  public function currentBinding():RubyBinding {
    return stack[0]; // FIXME
  }

  // move to go bag?
  private function reverseIterator<T>(iterable:Iterable<T>) {
    var reversed = new List<T>();
    for(element in iterable.iterator()) {
      reversed.push(element);
    }
    return reversed.iterator();
  }
}
