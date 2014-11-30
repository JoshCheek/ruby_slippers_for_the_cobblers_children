package ruby;

class RubyInterpreter {
  private var stack              : Array<RubyBinding>;
  private var objectSpace        : Array<RubyObject>;
  private var _currentExpression : RubyObject;
  private var workToDo           : List<Void -> RubyObject>;
  private var _toplevelNamespace : RubyClass;
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

    rubyNil             = new RubyObject(_toplevelNamespace); // should be NilClass
    rubyTrue            = new RubyObject(_toplevelNamespace); // should be TrueClass
    rubyFalse           = new RubyObject(_toplevelNamespace); // should be FalseClass
    _currentExpression  = rubyNil;
  }

  public function addCode(ast:Dynamic):Void {
    fillFrom(ast);
  }

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
      case _:
        // TODO: once we handle more cases, probably raise on this
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
