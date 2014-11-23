// TODO: figure out how to actually namespace
class RubyClass {
  var _name:String;

  public function new(name:String) {
    _name = name;
  }

  public function name():String {
    return _name;
  }

  public function instanceMethods(includeInherited:Bool):Array<String> {
    return ['THIS SHOULD BE THE INSTANCE METHODS'];
  }
}
