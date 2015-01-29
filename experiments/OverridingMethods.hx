class Parent {
  public function new() {}
  public function msg() return "parent";
  public function toChild1():Child1 { throw 'Cannot convert ${this} to Child1'; }
  public function toChild2():Child2 { throw 'Cannot convert ${this} to Child2'; }
}

class Child1 extends Parent {
  override public function msg() return "nil type";
  override public function toChild1() { return this; }
}
class Child2 extends Parent {
  override public function msg() return "true type";
  override public function toChild2() { return this; }
}


class OverridingMethods {
  public static function main() {
    var p1:Parent = new Child1();
    trace(p1.msg());

    var c1:Child1 = p1.toChild1();
    trace(c1.msg());

    trace('--------------------');

    var c2:Parent = new Child2();
    trace(c2.msg());

    var c2:Child2 = c2.toChild2();
    trace(c2.msg());

    trace('--------------------');

    try { var invalidChild:Child2 = c1.toChild2(); }
    catch(msg:String) {
      trace(msg);
    }
  }
}
