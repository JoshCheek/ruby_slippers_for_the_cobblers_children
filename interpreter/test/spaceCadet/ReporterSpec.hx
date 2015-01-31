package spaceCadet;
import spaceCadet.Reporter.StreamReporter;

class ReporterSpec {
  // not going to specify too much, b/c it's mostly all presentation and thus, volatile
  public static function describe(d:Description) {
    d.describe('Space Cadet StreamReporter', function(d) {
      var stdout   : StringOutput;
      var stderr   : StringOutput;
      var output   : Printer;
      var reporter : StreamReporter;
      var pos      = function(?p:haxe.PosInfos) { return p; }();

      d.before(function(a) {
        stdout   = new StringOutput();
        stderr   = new StringOutput();
        output   = new Printer(stdout, stderr);
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

      // NOTE: po,pa,f,pe = "pass one", "pass all", "pending", "fail", "thrown"
      d.it('prints successful specs', function(a) {
        a.eq(false, ~/myspec/.match(stdout.string));
        reporter.declareSpec("myspec", function(po,pa,pe,f,t) { po("", pos); pa(); });
        a.eq(true, ~/myspec/.match(stdout.string));
      });

      d.it('prints failing specs', function(a) {
        a.eq(false, ~/myspec/.match(stdout.string));
        reporter.declareSpec("myspec", function(po,pa,pe,f,t) f("", pos));
        a.eq(true, ~/myspec/.match(stdout.string));
      });

      d.it('prints pending specs', function(a) {
        a.eq(false, ~/myspec/.match(stdout.string));
        reporter.declareSpec("myspec", function(po,pa,pe,f,t) pe("", pos));
        a.eq(true, ~/myspec/.match(stdout.string));
      });

      d.it('prints failure messages', function(a) {
        a.eq(false, ~/failmsg/.match(stdout.string));
        reporter.declareSpec("myspec", function(po,pa,pe,f,t) f("failmsg", pos));
        a.eq(true, ~/failmsg/.match(stdout.string));
      });

      d.it('prints error messages and backtraces', function(a) {
        a.eq(false, ~/thefilename/.match(stdout.string));
        a.eq(false, ~/11223344/.match(stdout.string));
        reporter.declareSpec("thefilename",
          function(po,pa,pe,f,t) t("thrown", [FilePos(null, "thefilename", 11223344)])
        );
        a.eq(true, ~/thefilename/.match(stdout.string));
        a.eq(true, ~/11223344/.match(stdout.string));
      });

      // it includes the file/line number of the most recent passed assertion
      // it includes the file/line number of pending specs
      // it includes the backtrace of failed specs
      // it omits SpaceCadet internals from the backtrace

      d.it('prints summary info at the end', function(a) {
        a.eq(false, ~/\d+ passed/.match(stdout.string));
        reporter.finished();
        a.eq(true,  ~/Passed: \d+/.match(stdout.string));
      });
    });
  }
}
