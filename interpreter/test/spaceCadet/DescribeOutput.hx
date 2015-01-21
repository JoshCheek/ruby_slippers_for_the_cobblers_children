package spaceCadet;

class DescribeOutput {
  public static function describe(d:Description) {
    var outstream : StringOutput;
    var errstream : StringOutput;
    var output    : spaceCadet.Output;

    d.before(function(a) {
      outstream = new StringOutput();
      errstream = new StringOutput();
      output    = new Output(outstream, errstream);
    });

    d.describe('Space Cadet Output', function(d) {
      d.specify("#out writes its messages to the output stream with a newline", function(a) {
        a.eq("", outstream.string);
        a.eq("", errstream.string);
        output.out("a");
        a.eq("a\n", outstream.string);
        a.eq("",  errstream.string);
      });
    });
  }
}
