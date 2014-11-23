class RubyString extends RubyObject {
  public var value:String;

  public function withValue(value:String) {
    this.value = value;
    return this;
  }
}
