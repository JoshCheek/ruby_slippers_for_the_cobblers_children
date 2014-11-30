package ruby.ds.objects;

class RObject {
  public var klass             : RClass;
  public var instanceVariables : haxe.ds.StringMap<RObject>;

  public function new(klass:RClass) {
    this.klass             = klass;
    this.instanceVariables = new haxe.ds.StringMap();
  }
}
