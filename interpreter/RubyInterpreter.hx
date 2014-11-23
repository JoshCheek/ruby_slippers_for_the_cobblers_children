// TODO: figure out how to actually namespace
class RubyInterpreter {
  public function new() {
    // FIXME
  }

  public function addCode(code:Dynamic):Void {
    // FIXME
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

  public function evalNextExpression():Void {
    // FIXME
  }

  public function currentExpression():RubyObject {
    return new RubyObject().withDefaults();
  }
}
