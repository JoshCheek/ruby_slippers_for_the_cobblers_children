import spaceCadet.*;

class RunTests {
  static function main() {
    var hadFailure = false;
    // SpaceCadet
      // define
      var root = new Description();

      ruby.ParserSpec.describe(root);
      ruby.LanguageGoBagSpec.describe(root);
      ruby.BootstrappedWorldSpec.describe(root);
      ruby.WorldSpec.describe(root);
      ruby.InterpreterSpec.describe(root);

      spaceCadet.RunningASuiteSpec.describe(root);
      spaceCadet.AssertionsSpec.describe(root);
      spaceCadet.BeforeBlocksSpec.describe(root);
      spaceCadet.ReporterSpec.describe(root);

      toplevel.StackSpec.describe(root);
      toplevel.PrinterSpec.describe(root);
      toplevel.StringOutputSpec.describe(root);
      toplevel.EscapeStringSpec.describe(root);
      toplevel.InspectSpec.describe(root);

      // run
      var output   = new Printer(Sys.stdout(), Sys.stderr());
      var reporter = new Reporter.StreamReporter(output);
      Run.run(root, reporter, {failFast:true});
      hadFailure = hadFailure || 0 != reporter.numFailed;
      hadFailure = hadFailure || 0 != reporter.numErrored;

    // Finished
      if(hadFailure) Sys.exit(1);
  }
}
