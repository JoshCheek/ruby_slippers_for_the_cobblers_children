package ruby.ds.objects;

class RString extends RObject {
  public var value:String;

  public function new(value) {
    this.value = value;
    super(new RClass('SomeFuckingClass'));
  }
}
