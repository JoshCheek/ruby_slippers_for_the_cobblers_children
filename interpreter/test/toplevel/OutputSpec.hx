package toplevel;

class OutputSpec {
  public static function describe(d:spaceCadet.Description) {
    var outstream : StringOutput;
    var errstream : StringOutput;
    var output    : Output;
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

      d.specify("#resetln erases the contents of the current line without a newline", function(a) {
        assertOut("a\r\033[2Kb", function() output.write("a").resetln.write("b"));
      });

      d.specify('#yield receives a function and invokes it in order to not break up the call-chain', function(a) {
        output.write("1")
              .yield(function() output.write("2"))
              .yield(function() return 123)
              .yield(function() output.write("3"))
              .write("4");
        a.eq("1234", outstream.string);
      });

      d.describe("colour stack", function(d) {
        d.specify("fgBlack pushes black onto the colour stack", function(a) {
          output.fgBlack.write("X").fgPop.write("Y");
          a.eq("\033[30mX\033[39mY", outstream.string);
        });
        d.specify("fgRed pushes red onto the colour stack", function(a) {
          output.fgRed.write("X").fgPop.write("Y");
          a.eq("\033[31mX\033[39mY", outstream.string);
        });
        d.specify("fgGreen pushes green onto the colour stack", function(a) {
          output.fgGreen.write("X").fgPop.write("Y");
          a.eq("\033[32mX\033[39mY", outstream.string);
        });
        d.specify("fgYellow pushes yellow onto the colour stack", function(a) {
          output.fgYellow.write("X").fgPop.write("Y");
          a.eq("\033[33mX\033[39mY", outstream.string);
        });
        d.specify("fgBlue pushes blue onto the colour stack", function(a) {
          output.fgBlue.write("X").fgPop.write("Y");
          a.eq("\033[34mX\033[39mY", outstream.string);
        });
        d.specify("fgMagenta pushes magenta onto the colour stack", function(a) {
          output.fgMagenta.write("X").fgPop.write("Y");
          a.eq("\033[35mX\033[39mY", outstream.string);
        });
        d.specify("fgCyan pushes cyan onto the colour stack", function(a) {
          output.fgCyan.write("X").fgPop.write("Y");
          a.eq("\033[36mX\033[39mY", outstream.string);
        });
        d.specify("fgWhite pushes white onto the colour stack", function(a) {
          output.fgWhite.write("X").fgPop.write("Y");
          a.eq("\033[37mX\033[39mY", outstream.string);
        });

        d.specify("when told to colour the output, it tracks the current colour, allowing it to push/pop them", function(a) {
          assertOut(" a \033[31m b \033[32m c \033[31m d \033[39m e ", function() {
            output.write(" a ").fgRed.write(" b ").fgGreen.write(" c ").fgPop.write(" d ").fgPop.write(" e ");
          });
        });

        d.specify("fgPop raises if called with no colour stck", function(a) {
          var raised = false;
          try output.fgPop
          catch(e:String) {
            raised = true;
            a.eq(true, ~/stack/.match(e));
          }
          a.eq(true, raised);
        });

        d.it("does not preemptively apply colours", function(a) {
          output.fgRed
                .fgGreen
                .yield(function() a.eq("", outstream.string))
                .fgPop
                .yield(function() a.eq("", outstream.string))
                .write("X")
                .yield(function() a.eq("\033[31mX", outstream.string))
                .fgPop
                .write("Y")
                .yield(function() a.eq("\033[31mX\033[39mY", outstream.string));
        });
      });

      d.describe("indentation", function(d) {
        d.it("starts at 0 indentation", function(a) {
          output.write("a");
          a.eq("a", outstream.string);
        });
        d.it("can be told to indent", function(a) {
          output.indent.write("a");
          a.eq("  a", outstream.string);
        });
        d.it("can be told to outdent", function(a) {
          output.indent.outdent.write("a");
          a.eq("a", outstream.string);
        });
        d.specify("#writeln respects indentation, but doesn't preemptively write it", function(a) {
          output.indent.writeln("a").writeln("b");
          a.eq("  a\n  b\n", outstream.string);
        });
        d.specify("#resetln respects indentation, but doesn't preemptively write it", function(a) {
          output.indent.write("a")
                .resetln.write("b")
                .resetln;
          a.eq("  a\r\033[2K  b\r\033[2K", outstream.string);
        });
        d.it("can have multiple levels of indentation", function(a) {
          output.indent.indent.writeln("a")
                .outdent.writeln("b")
                .outdent.writeln("c");
          a.eq("    a\n"+
               "  b\n"+
               "c\n",
               outstream.string);
        });
        d.it("throws an error if outdenting when there is no indentation", function(a) {
          var raised = false;
          try output.outdent
          catch(e:String) {
            raised = true;
            a.eq(true, ~/no indentation/.match(e));
          }
          a.eq(true, raised);
        });
      });
    });
  }
}
