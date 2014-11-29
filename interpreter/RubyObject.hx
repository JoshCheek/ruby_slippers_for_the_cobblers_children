class RubyObject {
  public var klass             : RubyClass;
  public var instanceVariables : haxe.ds.StringMap<RubyObject>;

  public function new(klass:RubyClass) {
    this.klass             = klass;
    this.instanceVariables = new haxe.ds.StringMap();
  }
}
