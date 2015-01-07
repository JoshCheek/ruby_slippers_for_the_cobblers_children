package toplevel;
import haxe.unit.TestRunner;

class RunTests {
  public static function addTests(runner:TestRunner):TestRunner {
    runner.add(new TestStack());
    return runner;
  }

  static function main() {
    addTests(new TestRunner()).run();
  }
}
