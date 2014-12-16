// haxe -main ToStringOnRecord.hx -js ToString.js -dce full

typedef Wat = {
  whatevz:  String,
}

abstract Bbq(Wat) {
  inline public function new(self:Wat) {
    this = self;
  }

  public inline function toString() {
    return this.whatevz;
  }
}

class ToStringOnRecord {
  public static function main() {
    var w = new Bbq({whatevz: "omg"});
    trace(w);
  }
}
