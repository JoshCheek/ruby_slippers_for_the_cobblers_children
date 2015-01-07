class RunTests {
  static function main() {
    var runner = new haxe.unit.TestRunner();
    toplevel.RunTests.addTests(runner);
    ruby.RunTests.addTests(runner);

    var allPassed = runner.run();
    if(!allPassed) Sys.exit(1);
  }
}
