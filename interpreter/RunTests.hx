class RunTests {
  static function main() {
    var r = new haxe.unit.TestRunner();
    r.add(new TestInterpreter());
    // your can add others TestCase here

    // finally, run the tests
    r.run();
  }
}
