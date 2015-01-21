import spaceCadet.SpaceCadet;

class RunTests2 {
  static function main() {
    // define tests
    var root = new spaceCadet.SpaceCadet.Description();
    spaceCadet.DescribeRunningASuite.describe(root);
    spaceCadet.DescribeAssertions.describe(root);
    spaceCadet.DescribeBeforeBlocks.describe(root);

    // run and report
    var output   = new spaceCadet.SpaceCadet.Output(Sys.stdout(), Sys.stderr());
    var reporter = new spaceCadet.SpaceCadet.StreamReporter(output);
    spaceCadet.SpaceCadet.Run.run(root, reporter);

    if(reporter.numFails != 0) Sys.exit(1);
  }
}
