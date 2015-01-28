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
      spaceCadet.RunningASuiteSpec.describe(root);
      spaceCadet.AssertionsSpec.describe(root);
      spaceCadet.BeforeBlocksSpec.describe(root);
      spaceCadet.ReporterSpec.describe(root);
      toplevel.OutputSpec.describe(root);
      toplevel.StringOutputSpec.describe(root);
      toplevel.EscapeStringSpec.describe(root);
      toplevel.InspectSpec.describe(root);
      // run
      var output   = new Output(Sys.stdout(), Sys.stderr());
      var reporter = new Reporter.StreamReporter(output);
      Run.run(root, reporter, {failFast:true});
      hadFailure = hadFailure || 0 != reporter.numFailed;
      hadFailure = hadFailure || 0 != reporter.numErrored;

    // Finished
      if(hadFailure) Sys.exit(1);
  }
}
