package ruby.ds.objects;

class RBinding extends RObject {
  public var self      : RObject;
  public var defTarget : RClass;
  public var lvars     : InternalMap<RObject>;
}
