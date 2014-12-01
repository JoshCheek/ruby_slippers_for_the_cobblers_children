package ruby.ds.objects;

class RObject {
  public var klass             : RClass;
  public var instanceVariables : InternalMap<RObject>;

  public function new() null;
  // public function new(klass:RClass) {
  //   this.klass             = klass;
  //   this.instanceVariables = new InternalMap();
  // }
}
