package ruby.ds.objects;

class RClass extends RObject {
  public var name       : String;
  public var constants  : InternalMap<RObject>;
  public var imeths     : InternalMap<RMethod>;
  public var superclass : RClass;
}
