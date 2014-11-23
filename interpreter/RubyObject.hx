class RubyObject {
  public var klass:RubyClass;
  public var instanceVariables:String; // FIXME SYMBOL TABLE

  public function new() {
    // no op, treat this like a C struct
  }

  // TODO: instead of Dynamic, is there a way to return "current class"?
  //       so that subclasses can still call this method without casting or w/e
  public function withDefaults():Dynamic {
    this.klass = new RubyClass(); // FIXME, should be `Class`
    this.instanceVariables = "";
    return this;
  }
}
