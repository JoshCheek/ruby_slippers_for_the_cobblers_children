enum SomeEnum {
  AA(s:String);
  BB(s:Int);
}

class ConjunctionConcrete {
  public var num:Int;
  public var e:SomeEnum;
  public function new(e:SomeEnum, num:Int) {
    this.e = e;
    this.num = num;
  }
  @:to public function toSomeEnum() return e; // <-- this does not work, since its a class
}

@:forward(num)
abstract Conjunction(ConjunctionConcrete) {
  public function new(e:SomeEnum, num:Int) {
    this = new ConjunctionConcrete(e, num);
  }
  @:to public function toSomeEnum() return this.e;
}

class ConjunctionType {
  public static function data(se:SomeEnum) {
    switch(se) {
      case AA(s): return s;
      case BB(i): return Std.string(i);
    }
  }
  public static function main() {
    var a = new Conjunction(AA('abc'), 11);
    var b = new Conjunction(BB(123), 22);
    trace(a.num);
    trace(b.num);
    trace(data(a));
    trace(data(b));
  }
}

