package spaceCadet;
import spaceCadet.Reporter.StreamReporter;

class DescribeReporter {
  // not going to specify too much, b/c it's mostly all presentation and thus, volatile
  public static function describe(d:Description) {
    d.describe('Space Cadet StreamReporter', function(d) {
      var stdout   : StringOutput;
      var stderr   : StringOutput;
      var output   : Output;
      var reporter : StreamReporter;
      var pos      = function(?p:haxe.PosInfos) { return p; }();

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

      // NOTE: po,pa,f,pe = "pass one", "pass all", "pending", "fail"
      d.it('prints successful specs', function(a) {
        a.eq(false, ~/myspec/.match(stdout.string));
        reporter.declareSpec("myspec", function(po,pa,pe,f) { po("", pos); pa(); });
        a.eq(true, ~/myspec/.match(stdout.string));
      });

      d.it('prints failing specs', function(a) {
        a.eq(false, ~/myspec/.match(stdout.string));
        reporter.declareSpec("myspec", function(po,pa,pe,f) f("", pos));
        a.eq(true, ~/myspec/.match(stdout.string));
      });

      d.it('prints a backtrace for failing specs', function(a) {
        a.pending();
        reporter.declareSpec('myspec', function(po,pa,pe,f) {

        });
      });

      d.it('prints pending specs', function(a) {
        a.eq(false, ~/myspec/.match(stdout.string));
        reporter.declareSpec("myspec", function(po,pa,pe,f) pe("", pos));
        a.eq(true, ~/myspec/.match(stdout.string));
      });

      d.it('prints failure messages', function(a) {
        a.eq(false, ~/failmsg/.match(stdout.string));
        reporter.declareSpec("myspec", function(po,pa,pe,f) f("failmsg", pos));
        a.eq(true, ~/failmsg/.match(stdout.string));
      });

      // it includes the file/line number of the most recent passed assertion
      // it includes the file/line number of pending specs
      // it includes the backtrace of failed specs
      // it omits SpaceCadet internals from the backtrace

    });
  }
}
