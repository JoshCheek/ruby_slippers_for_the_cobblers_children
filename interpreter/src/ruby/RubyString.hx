package ruby;

class RubyString extends RubyObject {
  public var value:String;

  public function new(value) {
    this.value = value;
    super(new RubyClass('SomeFuckingClass'));
  }
}
