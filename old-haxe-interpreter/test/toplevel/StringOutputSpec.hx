package toplevel;

class StringOutputSpec {
  public static function construct(?str:String) {
    return new StringOutput(str);
  }

  // A good reference for what it should do is haxe.io.BytesOutput
  // https://github.com/HaxeFoundation/haxe/blob/156f6241058dc065172da04f1fab1d89eaa22472/std/haxe/io/BytesOutput.hx
  public static function describe(d:spaceCadet.Description) {
    d.describe("StringOutput", function(d) {
      var strio:StringOutput;

      d.before(function(a) {
        strio = construct();
      });

      d.it("Implements Output", function(a) {
        // passes if typechecker allows it to compile
        var o:haxe.io.Output = construct();
      });

      d.describe("Construction", function(d) {
        d.it("starts with an empty string if constructed with nothing", function(a) {
          a.eq("", new StringOutput().string);
        });

        d.it("accepts a string as the initial contents", function(a) {
          var o = new StringOutput("str");
          a.eq("str", o.string);
        });
      });

      d.specify("#string returns the current string", function(a) {
        a.eq("", strio.string);
        strio.writeString("1");
        a.eq("1", strio.string);
        strio.writeString("2");
        a.eq("12", strio.string);
      });

      d.specify("things written to it as bytes make their way into the string as characters", function(a) {
        strio.writeByte(65);
        a.eq("A", strio.string);
      });

      d.it("does not get byte-ified when writing strings", function(a) {
        strio.writeString("aåa");
        a.eq("aåa", strio.string);
      });

      d.it("can write escape sequences", function(a) {
        strio.writeString("\033[31m");
        a.eq("\033[31m", strio.string);
      });

      d.it('inspects with info about its string', function(a) {
        strio.writeString("hello");
        a.isTrue(~/StringOutput/.match(strio.inspect()));
        a.isTrue(~/hello/.match(strio.inspect()));
      });

    });
  }
}
