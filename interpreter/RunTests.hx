class RunTests {
  static function main() {
    var r = new haxe.unit.TestRunner();
    // r.add(new TestInterpreter());
    r.add(new TestParser());
    r.run();
  }
}
