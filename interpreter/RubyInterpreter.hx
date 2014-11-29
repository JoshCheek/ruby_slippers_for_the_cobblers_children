// TODO: figure out how to actually namespace
class RubyInterpreter {
  private var stack:Array<RubyBinding>;
  private var objectSpace:Array<RubyObject>;
  private var _currentExpression:RubyObject;
  // to think about: pass state instead of being void?
  private var workToDo:List<Void -> RubyObject>;
  private var _toplevelNamespace:RubyClass;

  // internally printed shit
  // stack
  // toplevel constant
  // toplevel binding
  // object space

  public function new() {
    workToDo            = new List();
    objectSpace         = [];
    _toplevelNamespace  = new RubyClass().withName('Object').withDefaults();
    var toplevelBinding = new RubyBinding({
      self:      new RubyObject().withDefaults(),
      defTarget: toplevelNamespace()
    });
    stack               = [toplevelBinding];
  }

  // e.g. `{ type => string, value => Josh }`
  public function addCode(ast:Dynamic):Void {
    fillFrom(ast);
  }

  public function drain() {
    _currentExpression = workToDo.pop()();
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
          var newString:RubyString = new RubyString().withDefaults();
          newString.value = value;
          return newString;
        });
      case SetLocalVariable(name, value):
        workToDo.push(function() {
          var obj = currentExpression();
          currentBinding().local_vars[name] = obj;
          return obj;
        });
        fillFrom(value);
      case GetLocalVariable(name):
        workToDo.push(function() {
          return currentBinding().local_vars[name];
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
            klass = new RubyClass().withName(name).withDefaults();
            toplevelNamespace().setConstant(name, klass);
          }
          stack.push(new RubyBinding({self: cast(klass, RubyClass), defTarget: cast(klass, RubyClass)}));
          return currentExpression(); // FIXME
        });

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
    return new RubyClass().withDefaults().withName('THIS SHOULD BE A CLASS');
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

  private function reverseIterator<T>(iterable:Iterable<T>) {
    var reversed = new List<T>();
    for(element in iterable.iterator()) {
      reversed.push(element);
    }
    return reversed.iterator();
  }
}
