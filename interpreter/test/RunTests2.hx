import spaceCadet.*;

class RunTests2 {
  static function main() {
    // define tests
    var root = new Description();
    DescribeRunningASuite.describe(root);
    DescribeAssertions.describe(root);
    DescribeBeforeBlocks.describe(root);

    // run and report
    var output   = new Output(Sys.stdout(), Sys.stderr());
    var reporter = new SpaceCadet.StreamReporter(output);
    spaceCadet.SpaceCadet.Run.run(root, reporter);

    if(reporter.numFails != 0) Sys.exit(1);
  }
}
