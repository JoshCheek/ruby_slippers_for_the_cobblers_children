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

      d.specify("#writeln writes its messages to the output stream with a newline", function(a) {
        assertOut("a\n", function() output.writeln("a"));
      });

      d.specify("#writeln does not add the newline if the message it is writing already ends in a newline", function(a) {
        assertOut("a\n", function() output.writeln("a\n"));
      });

      d.specify("#writeln can write blank lines", function(a) {
        assertOut("\n", function() output.writeln(""));
      });

      d.specify("#replaceln replaces the contents of the current line without a newline", function(a) {
        assertOut("a\rb", function() output.write("a").replaceln("b") );
      });

      d.describe("colour stack", function(d) {
        d.specify("when told to colour the output, it tracks the current colour, allowing it to push/pop them", function(a) {
          assertOut(" a \033[31m b \033[32m c \033[31m d \033[39m e ", function() {
            output.write(" a ").fgRed.write(" b ").fgGreen.write(" c ").fgPop.write(" d ").fgPop.write(" e ");
          });
        });

        d.specify("fgPop raises if called with no colour stck", function(a) {
          a.pending();
        });
      });
    });
  }
}
