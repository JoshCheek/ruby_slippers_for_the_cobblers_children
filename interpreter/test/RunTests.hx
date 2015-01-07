class RunTests {
  static function main() {
    var runner = new haxe.unit.TestRunner();
    toplevel.RunTests.addTests(runner);
    ruby.RunTests.addTests(runner);
    runner.run();
  }
}
