// No idea why, but you can only use implicit casting on abstract types.
// Personally, I don't see any reason why this shouldn't work for both of them.

class NotAbs {
  var n:Int;
  public function new(n:Int) {
    this.n = n;
  }
  @:from public static function fromInt(n:Int) {
    return new NotAbs(n);
  }
}

abstract Abs(Int) {
  public function new(n:Int) {
    this = n;
  }
  @:from public static function fromInt(n:Int) {
    return new Abs(n);
  }
}

class ImplicitCastingOnlyWorksForAbstract {
  public static function main() {
    // var a:NotAbs = 12; // <-- doesn't work
    var a:Abs = 12;
  }
}
