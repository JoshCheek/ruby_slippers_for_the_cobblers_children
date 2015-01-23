package spaceCadet;

// TODO: a.null, a.nNull, a.true, a.false
class DescribeAssertions {
  public static var currentLine(get,never):Int;
  static function get_currentLine() {
    var stack     = haxe.CallStack.callStack();
    var stackItem = stack[stack.length-3];
    // http://api.haxe.org/haxe/StackItem.html
    switch(stackItem) {
      case FilePos(s, file, line): return line;
      case _: throw "Unexpected haxe.StackItem: " + stackItem;
    }
  }

  public static function describe(d:Description) {
    d.describe('Space Cadet assertions', function(d) {
      var successMessage : String = null;
      var failureMessage : String = null;
      var pendingMessage : String = null;
      var recordedLine   : Int    = -1;
      var onSuccess = function(m, p) { successMessage = m; recordedLine = p.lineNumber; };
      var onFailure = function(m, p) { failureMessage = m; recordedLine = p.lineNumber; };
      var onPending = function(m, p) { pendingMessage = m; recordedLine = p.lineNumber; };
      var asserter  = new Asserter(onSuccess, onFailure, onPending);

      d.before(function(a) {
        recordedLine   = -1;
        successMessage = null;
        failureMessage = null;
        pendingMessage = null;
      });

      // positive assertions
      d.specify("eq passes when objects are ==", function(a) {
        asserter.eq(1, 2);
        a.eq(currentLine-1, recordedLine);
        a.eq(null, successMessage);

        asserter.eq(1, 1);
        a.eq(currentLine-1, recordedLine);
        a.eq(false, successMessage == null);
      });

      d.specify("eqm is the same as eq, but with a custom message",function(a) {
        asserter.eqm(1, 2, "zomg");
        a.eq(currentLine-1, recordedLine);
        a.eq(null, successMessage);

        asserter.eqm(1, 1, "zomg");
        a.eq(currentLine-1, recordedLine);
        a.eq("zomg", successMessage);
      });

      d.specify("streq passes when objects string representations are ==", function(a) {
        asserter.streq({}, {a:1});
        a.eq(currentLine-1, recordedLine);
        a.eq(null, successMessage);

        asserter.streq({}, {});
        a.eq(currentLine-1, recordedLine);
        a.eq(false, successMessage==null);
      });

      d.specify("streqm is the same as streq, but with a custom message",function(a) {
        asserter.streqm({}, {a:1}, "zomg");
        a.eq(currentLine-1, recordedLine);
        a.eq(null, successMessage);

        asserter.streqm({}, {}, "zomg");
        a.eq(currentLine-1, recordedLine);
        a.eq("zomg", successMessage);
      });

      // negative assertions
      d.specify("neq fails when objects are ==", function(a) {
        asserter.neq(1, 1);
        a.eq(currentLine-1, recordedLine);
        a.eq(null, successMessage);

        asserter.neq(1, 2);
        a.eq(currentLine-1, recordedLine);
        a.eq(false, successMessage == null);
      });

      d.specify("neqm is the same as neq, but with a custom message",function(a) {
        asserter.neqm(1, 1, "zomg");
        a.eq(currentLine-1, recordedLine);
        a.eq(null, successMessage);

        asserter.neqm(1, 2, "zomg");
        a.eq(currentLine-1, recordedLine);
        a.eq("zomg", successMessage);
      });

      d.specify("nstreq fails when objects string representations are ==", function(a) {
        asserter.nstreq({}, {});
        a.eq(currentLine-1, recordedLine);
        a.eq(null, successMessage);

        asserter.nstreq({}, {a:1});
        a.eq(currentLine-1, recordedLine);
        a.eq(false, successMessage==null);
      });

      d.specify("nstreqm is the same as nstreq, but with a custom message",function(a) {
        asserter.nstreqm({}, {}, "zomg");
        a.eq(currentLine-1, recordedLine);
        a.eq(null, successMessage);

        asserter.nstreqm({}, {a:1}, "zomg");
        a.eq(currentLine-1, recordedLine);
        a.eq("zomg", successMessage);
      });
    });
  }
}
