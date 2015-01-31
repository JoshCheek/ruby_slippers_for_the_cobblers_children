import spaceCadet.*;

class RunTests3 {
  static function main() {
    var root = new Description();

    // define
    // ruby3.ParseSpec.describe(root);
    // ruby3.LanguageGoBagSpec.describe(root);
    ruby3.BootstrappedWorldSpec.describe(root);
    // ruby3.InterpreterSpec.describe(root);


    // run
    var printer  = new Printer(Sys.stdout(), Sys.stderr());
    var reporter = new Reporter.StreamReporter(printer);
    Run.run(root, reporter, {failFast:true, printer: printer});

    // Finished
    var hadFailure = false;
    hadFailure = hadFailure || 0 != reporter.numFailed;
    hadFailure = hadFailure || 0 != reporter.numErrored;
    if(hadFailure) Sys.exit(1);
  }
}
