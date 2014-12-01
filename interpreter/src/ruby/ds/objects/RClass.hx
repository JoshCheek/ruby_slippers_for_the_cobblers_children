package ruby.ds.objects;

class RClass extends RObject {
  public var name       : String;
  public var constants  : InternalMap<RObject>;
  public var imeths     : InternalMap<RMethod>;
  public var superclass : RClass;

  public function getConstant(name:String):RObject {
    return constants.get(name);
  }

  public function setConstant(name:String, value:RObject):RObject {
    constants.set(name, value);
    return value;
  }

  public function hasMethod(methodName:String):Bool {
    return imeths.exists(methodName);
  }

  public function getMethod(methodName:String):RMethod {
    return imeths.get(methodName);
  }
}
