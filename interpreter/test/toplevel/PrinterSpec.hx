package toplevel;

class PrinterSpec {
  public static function describe(d:spaceCadet.Description) {
    var outstream : StringOutput;
    var errstream : StringOutput;
    var printer   : Printer;
    var assertOut : String -> (Void -> Void) -> Void;

    d.before(function(a) {
      outstream = new StringOutput();
      errstream = new StringOutput();
      printer    = new Printer(outstream, errstream);
      assertOut = function(s, f) {
        a.eq("", outstream.string);
        a.eq("", errstream.string);
        f();
        a.eq(s,  outstream.string);
        a.eq("", errstream.string);
      }
    });

    d.describe('Printer', function(d) {
      d.it('inspects without fucking blowing up', function(a) {
        a.isTrue(~/#<Printer/.match(printer.inspect()));
      });

      d.specify("#write writes its messages to the output stream without a newline", function(a) {
        assertOut("a", function() printer.write("a"));
      });

      d.specify("#writeln writes its messages to the output stream with a newline", function(a) {
        assertOut("a\n", function() printer.writeln("a"));
      });

      d.specify("#writeln does not add the newline if the message it is writing already ends in a newline", function(a) {
        assertOut("a\n", function() printer.writeln("a\n"));
      });

      d.specify("#writeln can write blank lines", function(a) {
        assertOut("\n", function() printer.writeln(""));
      });

      d.specify("#resetln erases the contents of the current line without a newline", function(a) {
        assertOut("a\r\033[2Kb", function() printer.write("a").resetln.write("b"));
      });

      d.specify('#yield receives a function and invokes it in order to not break up the call-chain', function(a) {
        printer.write("1")
               .yield(function() printer.write("2"))
               .yield(function() return 123)
               .yield(function() printer.write("3"))
               .write("4");
        a.eq("1234", outstream.string);
      });

      d.specify('#d optionally takes a (Type,Message), (Message), or nothing, and prints them as debug output... but to normal output, so they don\'t interleave.', function(a) {
        printer.d("THE TYPE", "TYPED MESSAGE");
        printer.d();
        printer.d("UNTYPED MESSAGE");

        var lines = outstream.string.split("\n");

        a.eq(4, lines.length); // there's a trailing newline, and split gives an empty string to the RHS of it
        a.isTrue(~/THE TYPE/.match(lines[0]));
        a.isTrue(~/TYPED MESSAGE/.match(lines[0]));
        a.isFalse(~/T/.match(lines[1])); // didn't print whatevs
        a.isTrue(~/UNTYPED MESSAGE/.match(lines[2]));
      });

      d.specify('#d will inspect the message if it isn\'t a string', function(a) {
        printer.d({a: 1}).d("msg", {b: 2});
        // a.p.d({only: "object"}).d().d("message", {with: "object"}).d("just message").d("category", "and message");
        var lines = outstream.string.split("\n");
        a.isTrue(~/\{a: 1\}/.match(lines[0]));
        a.isTrue(~/[^"]msg[^"].*?\{b: 2\}/.match(lines[1]));
      });

      d.describe("colour stack", function(d) {
        d.specify("fgBlack pushes black onto the colour stack", function(a) {
          printer.fgBlack.write("X").fgPop.write("Y");
          a.eq("\033[30mX\033[39mY", outstream.string);
        });
        d.specify("fgRed pushes red onto the colour stack", function(a) {
          printer.fgRed.write("X").fgPop.write("Y");
          a.eq("\033[31mX\033[39mY", outstream.string);
        });
        d.specify("fgGreen pushes green onto the colour stack", function(a) {
          printer.fgGreen.write("X").fgPop.write("Y");
          a.eq("\033[32mX\033[39mY", outstream.string);
        });
        d.specify("fgYellow pushes yellow onto the colour stack", function(a) {
          printer.fgYellow.write("X").fgPop.write("Y");
          a.eq("\033[33mX\033[39mY", outstream.string);
        });
        d.specify("fgBlue pushes blue onto the colour stack", function(a) {
          printer.fgBlue.write("X").fgPop.write("Y");
          a.eq("\033[34mX\033[39mY", outstream.string);
        });
        d.specify("fgMagenta pushes magenta onto the colour stack", function(a) {
          printer.fgMagenta.write("X").fgPop.write("Y");
          a.eq("\033[35mX\033[39mY", outstream.string);
        });
        d.specify("fgCyan pushes cyan onto the colour stack", function(a) {
          printer.fgCyan.write("X").fgPop.write("Y");
          a.eq("\033[36mX\033[39mY", outstream.string);
        });
        d.specify("fgWhite pushes white onto the colour stack", function(a) {
          printer.fgWhite.write("X").fgPop.write("Y");
          a.eq("\033[37mX\033[39mY", outstream.string);
        });

        d.specify("when told to colour the output, it tracks the current colour, allowing it to push/pop them", function(a) {
          assertOut(" a \033[31m b \033[32m c \033[31m d \033[39m e ", function() {
            printer.write(" a ").fgRed.write(" b ").fgGreen.write(" c ").fgPop.write(" d ").fgPop.write(" e ");
          });
        });

        d.specify("fgPop raises if called with no colour stck", function(a) {
          var raised = false;
          try printer.fgPop
          catch(e:String) {
            raised = true;
            a.eq(true, ~/stack/.match(e));
          }
          a.eq(true, raised);
        });

        d.it("does not preemptively apply colours", function(a) {
          printer.fgRed
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
          printer.write("a");
          a.eq("a", outstream.string);
        });
        d.it("can be told to indent", function(a) {
          printer.indent.write("a");
          a.eq("  a", outstream.string);
        });
        d.it("can be told to outdent", function(a) {
          printer.indent.outdent.write("a");
          a.eq("a", outstream.string);
        });
        d.specify("#writeln respects indentation, but doesn't preemptively write it", function(a) {
          printer.indent.writeln("a").writeln("b");
          a.eq("  a\n  b\n", outstream.string);
        });
        d.specify("#resetln respects indentation, but doesn't preemptively write it", function(a) {
          printer.indent.write("a")
                .resetln.write("b")
                .resetln;
          a.eq("  a\r\033[2K  b\r\033[2K", outstream.string);
        });
        d.it("can have multiple levels of indentation", function(a) {
          printer.indent.indent.writeln("a")
                 .outdent.writeln("b")
                 .outdent.writeln("c");
          a.eq("    a\n"+
               "  b\n"+
               "c\n",
               outstream.string);
        });
        d.it("throws an error if outdenting when there is no indentation", function(a) {
          var raised = false;
          try printer.outdent
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
