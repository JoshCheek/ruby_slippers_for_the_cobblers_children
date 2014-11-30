package ruby.ds.objects;

class RClass extends RObject {
  public var name            : String;
  public var constants       : haxe.ds.StringMap<RObject>;
  public var instanceMethods : haxe.ds.StringMap<RMethod>;
  public var superclass      : RClass;

  public function new(name) {
    super(this); // FIXME: should only be one Class
    this.name            = name;
    this.constants       = new haxe.ds.StringMap();
    this.instanceMethods = new haxe.ds.StringMap();
    this.superclass      = null; // FIXME
  }

  public function getConstant(name:String):RObject {
    return constants.get(name);
  }

  public function setConstant(name:String, value:RObject):RObject {
    constants.set(name, value);
    return value;
  }

  public function hasMethod(methodName:String):Bool {
    return instanceMethods.exists(methodName);
  }

  public function getMethod(methodName:String):RMethod {
    return instanceMethods.get(methodName);
  }
}
