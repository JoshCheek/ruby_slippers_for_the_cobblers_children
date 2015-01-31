import spaceCadet.*;

class RunTests4 {
  static function main() {
    var root = new Description();

    // define
    ruby4.ParseSpec.describe(root);
    ruby4.LanguageGoBagSpec.describe(root);
    ruby4.BootstrappedWorldSpec.describe(root);
    ruby4.InterpreterSpec.describe(root);


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
