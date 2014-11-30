package ruby.ds.objects;

class RSymbol extends RObject {
  public var name : String;

  public function new(name) {
    super(new RClass("Symbol")); // FIXME
    this.name = name;
  }
}
