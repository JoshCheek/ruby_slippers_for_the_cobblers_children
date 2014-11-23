// TODO: figure out how to actually namespace
class RubyInterpreter {
  public function new() {
  }

  public function addCode(code:Dynamic):Void {
  }

  public function evalAll():Void {
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
}
