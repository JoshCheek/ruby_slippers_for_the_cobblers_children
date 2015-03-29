package spaceCadet;

enum Testable {
  One(name:String,  body:AssertBlock);
  Many(name:String, desc:Description);
}

class Description {
  public var beforeBlocks : Array<AssertBlock>;
  public var testables    : Array<Testable>;

  public function new() {
    this.beforeBlocks = [];
    this.testables    = [];
  }

  public function describe(name, body) {
    var child = new Description();
    testables.push(Many(name, child));
    body(child);
    return this;
  }
  public function context(name, body) return describe(name, body);

  public function before(beforeBlock) {
    this.beforeBlocks.push(beforeBlock);
    return this;
  }

  public function it(name, body) {
    this.testables.push(One(name, body));
    return this;
  }

  // why can't I do this?: public function specify = it;
  public function specify(name, body) return it(name, body);
  public function example(name, body) return it(name, body);
}
