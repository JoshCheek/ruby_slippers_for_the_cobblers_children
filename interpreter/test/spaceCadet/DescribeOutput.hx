package spaceCadet;

class DescribeOutput {
  public static function describe(d:Description) {
    var outstream : StringOutput;
    var errstream : StringOutput;
    var output    : spaceCadet.Output;
    var assertOut : String -> (Void -> Void) -> Void;

    d.before(function(a) {
      outstream = new StringOutput();
      errstream = new StringOutput();
      output    = new Output(outstream, errstream);
      assertOut = function(s, f) {
        a.eq("", outstream.string);
        a.eq("", errstream.string);
        f();
        a.eq(s,  outstream.string);
        a.eq("", errstream.string);
      }
    });

    d.describe('Space Cadet Output', function(d) {
      d.specify("#write writes its messages to the output stream without a newline", function(a) {
        assertOut("a", function() output.write("a"));
      });

      d.specify("#writeln writes its messages to the output stream without a newline", function(a) {
        assertOut("a\n", function() output.writeln("a"));
      });

      d.specify("#writeln does not add the newline if the message it is writing already ends in a newline", function(a) {
        assertOut("a\n", function() output.writeln("a"));
      });

      d.specify("#replaceln replaces the contents of the current line without a newline", function(a) {
        assertOut("a\rb", function() {
          output.write("a").replaceln("b");
        });
      });
    });
  }
}
