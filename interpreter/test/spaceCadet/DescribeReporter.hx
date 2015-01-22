package spaceCadet;
import spaceCadet.Reporter.StreamReporter;

class DescribeReporter {
  public static function describe(d:Description) {
    d.describe('Space Cadet StreamReporter', function(d) {
      var stdout   : StringOutput;
      var stderr   : StringOutput;
      var output   : Output;
      var reporter : StreamReporter;

      d.before(function(a) {
        stdout   = new StringOutput();
        stderr   = new StringOutput();
        output   = new Output(stdout, stderr);
        reporter = new StreamReporter(output);
      });

      d.it('implements the Reporter interface', function(a) {
        var a:Reporter = new StreamReporter(output);
      });

      d.it('prints descriptions', function(a) {
        a.eq(false, ~/mydesc/.match(stdout.string));
        reporter.declareDescription("mydesc", function(){});
        a.eq(true, ~/mydesc/.match(stdout.string));
      });

      // NOTE: po,pa,f,pe = "pass one", "pass all", "fail", "pending"
      d.it('prints successful specs', function(a) {
        a.eq(false, ~/myspec/.match(stdout.string));
        reporter.declareSpec("myspec", function(po,pa,f,pe) { po(""); pa(); });
        a.eq(true, ~/myspec/.match(stdout.string));
      });

      d.it('prints failing specs', function(a) {
        a.eq(false, ~/myspec/.match(stdout.string));
        reporter.declareSpec("myspec", function(po,pa,f,pe) f(""));
        a.eq(true, ~/myspec/.match(stdout.string));
      });

      d.it('prints pending specs', function(a) {
        a.eq(false, ~/myspec/.match(stdout.string));
        reporter.declareSpec("myspec", function(po,pa,f,pe) pe(""));
        a.eq(true, ~/myspec/.match(stdout.string));
      });

      d.it('prints failure messages', function(a) {
        a.eq(false, ~/failmsg/.match(stdout.string));
        reporter.declareSpec("myspec", function(po,pa,f,pe) f("failmsg"));
        a.eq(true, ~/failmsg/.match(stdout.string));
      });


      // not going to specify much more than this, b/c it's all presentation
    });
  }
}
