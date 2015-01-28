package spaceCadet;

class BeforeBlocksSpec {
  public static function describe(d:Description) {
    var noop = function(_:Dynamic) { };

    var desc     : Description;
    var reporter : MockReporter;
    var run      : Void->Void;

    d.before(function(a) {
      desc     = new Description();
      reporter = new MockReporter();
      run      = function() Run.run(desc, reporter);
    });

    d.describe('Space Cadet before blocks', function(d) {
      d.it('runs before blocks prior to each test', function(a) {
        var seen = [];
        desc.before(function(_) seen.push("before"));
        desc.it("it1", function(_) seen.push("it1"));
        desc.it("it2", function(_) seen.push("it2"));
        run();
        a.streq(["before", "it1", "before", "it2"], seen);
      });

      d.it('runs before blocks in the order they were defined in', function(a) {
        var seen = [];
        desc.before(function(_) seen.push("before1"));
        desc.before(function(_) seen.push("before2"));
        desc.it("it2", noop);
        run();
        a.streq(["before1", "before2"], seen);
      });

      d.it('runs parent before blocks prior to children before blocks', function(a) {
        var seen = [];
        desc.describe("", function(d) {
          d.before(function(_) seen.push("before2"));
          d.it("", noop);
        });
        desc.before(function(_) seen.push("before1"));
        run();
        a.streq(["before1", "before2"], seen);
      });

      d.it('does not run child before blocks on their parents', function(a) {
        var seen = [];
        desc.before(function(_) seen.push("parent"));
        desc.describe("", function(d) {
          d.before(function(_) seen.push("child"));
        });
        desc.it("", noop);
        run();
        a.streq(["parent"], seen);
      });

      d.it('does not call a before block when there is no spec for it to be before', function(a) {
        var seen = [];
        desc.before(function(_) seen.push("parent"));
        desc.describe("", function(d) {
          d.before(function(_) seen.push("child"));
        });
        run();
        a.streq([], seen);
      });

      d.specify('assertions in before blocks apply to the spec they are before', function(a) {
        desc.describe("success", function(d) {
          d.before(function(a) a.eq(1, 1));
          d.it("s", noop);
        });
        desc.describe("failure", function(d) {
          d.before(function(a) a.eq(2, 1));
          d.it("s", noop);
        });
        desc.describe("pending", function(d) {
          d.before(function(a) a.pending());
          d.it("s", noop);
        });

        run();

        var s = reporter.crnt.descriptions.get("success").specifications.get("s");
        var f = reporter.crnt.descriptions.get("failure").specifications.get("s");
        var p = reporter.crnt.descriptions.get("pending").specifications.get("s");

        a.eq(1, s.numSucceeded);
        a.eq(0, f.numSucceeded);
        a.eq(0, p.numSucceeded);

        a.eq(true,  s.didSucceed);
        a.eq(false, f.didSucceed);
        a.eq(false, p.didSucceed);

        a.eq(false, s.isPending);
        a.eq(false, f.isPending);
        a.eq(true,  p.isPending);
      });
    });
  };
}
