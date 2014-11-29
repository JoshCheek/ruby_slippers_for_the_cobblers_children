package ruby;

class RubyClass extends RubyObject {
  public var name            : String;
  public var constants       : haxe.ds.StringMap<RubyObject>;
  public var instanceMethods : haxe.ds.StringMap<RubyAst>;

  public function new(name) {
    super(this); // FIXME: should only be one Class
    this.name            = name;
    this.constants       = new haxe.ds.StringMap();
    this.instanceMethods = new haxe.ds.StringMap();
  }

  public function getConstant(name:String):RubyObject {
    return constants.get(name);
  }

  public function setConstant(name:String, value:RubyObject):RubyObject {
    constants.set(name, value);
    return value;
  }
}
