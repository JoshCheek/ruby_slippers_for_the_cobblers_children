// TODO: figure out how to actually namespace
class RubyClass extends RubyObject {
  public var constants:haxe.ds.StringMap<RubyObject>;
  public var name:String;
  public var instanceMethods:Array<String>;

  public function new() {
    super();
    constants = new haxe.ds.StringMap();
  }

  public function withName(name:String):RubyClass {
    this.name = name;
    return this;
  }

  public function getConstant(name:String):RubyObject {
    return constants.get(name);
  }

  public function setConstant(name:String, value:RubyObject):RubyObject {
    constants.set(name, value);
    return value;
  }
}
