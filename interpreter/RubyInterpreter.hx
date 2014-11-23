// TODO: figure out how to actually namespace
class RubyInterpreter {
  private var ast:Dynamic;
  //private var stack:Array<Binding>;
  private var objectSpace:Array<RubyObject>;
  // internally printed shit
  // stack
  // toplevel constant
  // toplevel binding
  // object space

  public function new() {
    // FIXME
    this.objectSpace = [];
  }

  // e.g. `{ type => string, value => Josh }`
  public function addCode(ast:Dynamic):Void {
    this.ast = ast;
  }

  public function evalNextExpression():Void {
    var newString:RubyString = new RubyString().withDefaults();
    newString.value = ast.value;
    objectSpace.push(newString);
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
    return objectSpace[objectSpace.length - 1];
  }
}
