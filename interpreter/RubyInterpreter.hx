// TODO: figure out how to actually namespace
class RubyInterpreter {
  private var ast:Dynamic;
  private var stack:Array<RubyBinding>;
  private var objectSpace:Array<RubyObject>;
  private var _currentExpression:RubyObject;
  // to think about: pass state instead of being void?
  private var workToDo:Array<Void -> RubyObject>;

  // internally printed shit
  // stack
  // toplevel constant
  // toplevel binding
  // object space

  public function new() {
    var toplevelBinding = new RubyBinding();
    stack               = [toplevelBinding];
    objectSpace         = [];
  }

  // e.g. `{ type => string, value => Josh }`
  public function addCode(ast:Dynamic):Void {
    this.ast = ast;
    fillFrom(ast);
  }

  public function drain() {
    _currentExpression = workToDo.pop()();
  }

  public function fillFrom(ast) {
    if(ast.type == 'expressions') {
      var expressions:Array<Dynamic> = ast.expressions;
      trace(expressions);
      for(expr in expressions.reverse().iterator()) {
        fillFrom(expr);
      };
    } else if(ast.type == 'string') {
      drain.push(function() {
        var newString:RubyString = new RubyString().withDefaults();
        newString.value = ast.value;
        return newString;
      });

    } else if (ast.type == 'set_local_variable') {
      workToDo.push(function() {
        var obj = currentExpression();
        currentBinding().local_vars[ast.name] = obj;
        return obj;
      });
      fillFrom(ast.value);

    } else if (ast.type == 'get_local_variable') {
      workToDo.push(function() {
        return currentBinding().local_vars[ast.name];
      });
    }

    // return currentExpression();
  }


  public function evalAll():Void {
    // FIXME
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
}
