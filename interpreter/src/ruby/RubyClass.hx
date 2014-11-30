package ruby;

class RubyClass extends RubyObject {
  public var name            : String;
  public var constants       : haxe.ds.StringMap<RubyObject>;
  public var instanceMethods : haxe.ds.StringMap<RubyMethod>;
  public var superclass      : RubyClass;

  public function new(name) {
    super(this); // FIXME: should only be one Class
    this.name            = name;
    this.constants       = new haxe.ds.StringMap();
    this.instanceMethods = new haxe.ds.StringMap();
    this.superclass      = null; // FIXME
  }

  public function getConstant(name:String):RubyObject {
    return constants.get(name);
  }

  public function setConstant(name:String, value:RubyObject):RubyObject {
    constants.set(name, value);
    return value;
  }

  public function hasMethod(methodName:String):Bool {
    return instanceMethods.exists(methodName);
  }

  public function getMethod(methodName:String):RubyMethod {
    return instanceMethods.get(methodName);
  }
}
