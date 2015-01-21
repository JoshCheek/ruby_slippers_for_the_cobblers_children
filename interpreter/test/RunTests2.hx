import spaceCadet.SpaceCadet;

class DescribeStack {
  public static function describe(d) {
    d.describe('Stack Test', function(d) {
      var int_stack    : Array<Int>;
      var string_stack : Array<String>;

      d.before(function(lg) {
        int_stack    = new Array<Int>();
        string_stack = new Array<String>();
      });

      d.it('has 0 length initially', function(a) {
        a.eq(int_stack.length, 0);
        a.eq(string_stack.length, 0);
        a.eq(string_stack.length, 1);
        a.eq(string_stack.length, 0);
      });
    });
  }
}

class RunTests2 {
  static function main() {
    // define tests
    var root = new spaceCadet.SpaceCadet.Description();
    DescribeStack.describe(root);
    spaceCadet.SpaceCadetDesc.SpaceCadetDesc.describe(root);

    // run and report
    var output   = new spaceCadet.SpaceCadet.Output(Sys.stdout(), Sys.stderr());
    var reporter = new spaceCadet.SpaceCadet.Reporter(output);
    Run.run(root, reporter);

    // if(!allPassed) Sys.exit(1);
  }
}
