import spaceCadet.*;

class RunTests {
  static function main() {
    var hadFailure = false;
    // haxe.unit
      var runner = new haxe.unit.TestRunner();
      toplevel.RunTests.addTests(runner);
      ruby.RunTests.addTests(runner);
      hadFailure = hadFailure || !runner.run();

    // SpaceCadet
      // define
      var root = new Description();
      spaceCadet.DescribeRunningASuite.describe(root);
      spaceCadet.DescribeAssertions.describe(root);
      spaceCadet.DescribeBeforeBlocks.describe(root);
      spaceCadet.DescribeReporter.describe(root);
      toplevel.DescribeOutput.describe(root);
      toplevel.DescribeStringOutput.describe(root);
      toplevel.DescribeEscapeString.describe(root);
      toplevel.DescribeInspect.describe(root);
      // run
      var output   = new Output(Sys.stdout(), Sys.stderr());
      var reporter = new Reporter.StreamReporter(output);
      Run.run(root, reporter);
      hadFailure = hadFailure || 0 != reporter.numFails;

    // Exit status
      if(hadFailure) Sys.exit(1);
  }
}
