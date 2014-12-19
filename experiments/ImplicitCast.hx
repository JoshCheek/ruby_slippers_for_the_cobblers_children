// I can't figure out how the from/to thing works >.<

abstract MyAbstract(Int) {
  inline function new(i:Int) {
    this = i;
  }

  @:from
  static public function fromString(s:String) {
    return new MyAbstract(Std.parseInt(s));
  }

  @:to
  public function toArray() {
    return [this];
  }
}

abstract ArrayListConversion(Array<Int>) {
  public function new(a:Array<Int>):List {
    this = a;
  }

  @:from
  static public function fromArrayOfInt(ary:Array<Int>) {
    return new ArrayListConversion(ary);
  }

  @:to
  public function toListOfInt():List<Int> {
    var l = new List();
    for(e in this) l.push(e);
    return l;
  }
}


class ImplicitCast {
  static public function main() {
    // their example
    var a:MyAbstract = "3";
    var b:Array<Int> = a;
    trace(b); // [3]

    // my example. Sigh, not what I want. Can't figure out how to use this thing :(
    var c:ArrayListConversion = [1,2,3];
    var d:List<Int> = c;
    trace(d); // {3, 2, 1}

    // examples of what I would be happy with:
    // Totally implicit:
    //   var l:List<Int> = [1,2,3];
    // Explicit, but on obvious classes:
    //   var l = List.from([1,2,3]);
  }
}
