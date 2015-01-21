import spaceCadet.*;

class RunTests {
  static function main() {
    // haxe.unit tests
    var runner = new haxe.unit.TestRunner();
    toplevel.RunTests.addTests(runner);
    ruby.RunTests.addTests(runner);
    var haxeUnitPassed = runner.run();

    // SpaceCadet tests
    var root = new Description();
    toplevel.DescribeStringOutput.describe(root);
    var output   = new Output(Sys.stdout(), Sys.stderr());
    var reporter = new Reporter.StreamReporter(output);
    Run.run(root, reporter);
    var spaceCadetPassed = reporter.numFails == 0;

    // exiting
    var hadFailure = !haxeUnitPassed || !spaceCadetPassed;
    if(hadFailure) Sys.exit(1);
  }
}
