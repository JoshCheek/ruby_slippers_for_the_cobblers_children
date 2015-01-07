package toplevel;
import haxe.unit.TestRunner;

class RunTests {
  public static function addTests(runner:TestRunner):TestRunner {
    runner.add(new TestStack());
    return runner;
  }

  static function main() {
    var runner    = addTests(new TestRunner());
    var allPassed = runner.run();
    if(!allPassed) Sys.exit(1);
  }
}
