import spaceCadet.*;

class RunTests2 {
  static function main() {
    var root = new Description();

    // define
    ruby2.ParseSpec.describe(root);
    ruby2.LanguageGoBagSpec.describe(root);
    // ruby2.BootstrappedWorldSpec.describe(root);
    ruby2.InterpreterSpec.describe(root);

    // run
    var output   = new Output(Sys.stdout(), Sys.stderr());
    var reporter = new Reporter.StreamReporter(output);
    Run.run(root, reporter, {failFast:true});

    // Finished
    var hadFailure = false;
    hadFailure = hadFailure || 0 != reporter.numFailed;
    hadFailure = hadFailure || 0 != reporter.numErrored;
    if(hadFailure) Sys.exit(1);
  }
}
