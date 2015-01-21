package spaceCadet;
import spaceCadet.SpaceCadet;

class DescribeAssertions {
  public static function describe(d:Description) {
    d.describe('Space Cadet assertions', function(d) {
      var successMessage:String = null;
      var failureMessage:String = null;
      var pendingMessage:String = null;
      var onSuccess = function(m) { successMessage = m; };
      var onFailure = function(m) { failureMessage = m; };
      var onPending = function(m) { pendingMessage = m; };
      var asserter  = new Asserter(onSuccess, onFailure, onPending);

      d.before(function(a) {
        successMessage = null;
        failureMessage = null;
        pendingMessage = null;
      });

      // positive assertions
      d.specify("eq passes when objects are ==", function(a) {
        a.eq(null, successMessage);
        asserter.eq(1, 2);
        a.eq(null, successMessage);
        asserter.eq(1, 1);
        a.eq(false, successMessage == null);
      });

      d.specify("eqm is the same as eq, but with a custom message",function(a) {
        a.eq(null, successMessage);
        asserter.eqm(1, 2, "zomg");
        a.eq(null, successMessage);
        asserter.eqm(1, 1, "zomg");
        a.eq("zomg", successMessage);
      });

      d.specify("streq passes when objects string representations are ==", function(a) {
        a.eq(null, successMessage);
        asserter.streq({}, {a:1});
        a.eq(null, successMessage);
        asserter.streq({}, {});
        a.eq(false, successMessage==null);
      });

      d.specify("streqm is the same as streq, but with a custom message",function(a) {
        a.eq(null, successMessage);
        asserter.streqm({}, {a:1}, "zomg");
        a.eq(null, successMessage);
        asserter.streqm({}, {}, "zomg");
        a.eq("zomg", successMessage);
      });

      // negative assertions
      d.specify("neq fails when objects are ==", function(a) {
        a.eq(null, successMessage);
        asserter.neq(1, 1);
        a.eq(null, successMessage);
        asserter.neq(1, 2);
        a.eq(false, successMessage == null);
      });

      d.specify("neqm is the same as neq, but with a custom message",function(a) {
        a.eq(null, successMessage);
        asserter.neqm(1, 1, "zomg");
        a.eq(null, successMessage);
        asserter.neqm(1, 2, "zomg");
        a.eq("zomg", successMessage);
      });

      d.specify("nstreq fails when objects string representations are ==", function(a) {
        a.eq(null, successMessage);
        asserter.nstreq({}, {});
        a.eq(null, successMessage);
        asserter.nstreq({}, {a:1});
        a.eq(false, successMessage==null);
      });

      d.specify("nstreqm is the same as nstreq, but with a custom message",function(a) {
        a.eq(null, successMessage);
        asserter.nstreqm({}, {}, "zomg");
        a.eq(null, successMessage);
        asserter.nstreqm({}, {a:1}, "zomg");
        a.eq("zomg", successMessage);
      });
    });
  }
}
