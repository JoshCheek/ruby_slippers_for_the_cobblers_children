package ruby.ds.objects;

typedef RObject = {
  public var klass : RClass;
  public var ivars : InternalMap<RObject>;
}
