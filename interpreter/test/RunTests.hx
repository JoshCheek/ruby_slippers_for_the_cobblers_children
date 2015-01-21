import spaceCadet.*;

class RunTests {
  static function main() {
    // haxe.unit
      var runner = new haxe.unit.TestRunner();
      toplevel.RunTests.addTests(runner);
      ruby.RunTests.addTests(runner);
      var haxeUnitPassed = runner.run();

    // SpaceCadet
      // define
      var root = new Description();
      spaceCadet.DescribeRunningASuite.describe(root);
      spaceCadet.DescribeAssertions.describe(root);
      spaceCadet.DescribeBeforeBlocks.describe(root);
      spaceCadet.DescribeReporter.describe(root);
      spaceCadet.DescribeOutput.describe(root);
      toplevel.DescribeStringOutput.describe(root);
      // run
      var output   = new Output(Sys.stdout(), Sys.stderr());
      var reporter = new Reporter.StreamReporter(output);
      Run.run(root, reporter);
      var spaceCadetPassed = reporter.numFails == 0;

    // Exit status
      var hadFailure = !haxeUnitPassed || !spaceCadetPassed;
      if(hadFailure) Sys.exit(1);
  }
}
