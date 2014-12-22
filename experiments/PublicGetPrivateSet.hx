class Other {
  public var x(default, null):Int;
  public function new()    { x = 1; }
  public function double() { x *= 2; }
}

class PublicGetPrivateSet {

  public static function main() {
    var o = new Other();
    trace(o.x);
    o.double();
    trace(o.x);
    // o.x = 3; // fails b/c there is no public setter
  }
}
