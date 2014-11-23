// TODO: figure out how to actually namespace
class RubyClass extends RubyObject {
  public var name:String;
  public var instanceMethods:Array<String>;

  public function withName(name:String):RubyClass {
    this.name = name;
    return this;
  }
}
