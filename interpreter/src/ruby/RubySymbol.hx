package ruby;

class RubySymbol extends RubyObject {
  public var name : String;

  public function new(name) {
    super(new RubyClass("Symbol")); // FIXME
    this.name = name;
  }
}
