package ruby.ds.objects;

class RObject {
  public var klass : RClass;
  public var ivars : InternalMap<RObject>;

  public function new() null;
}
