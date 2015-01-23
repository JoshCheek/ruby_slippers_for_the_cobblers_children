package toplevel;

// TODO: haxe.Int32, haxe.Int64
class DescribeInspect {
  public static function inspect(str:Dynamic) {
    return Inspect.call(str);
  }

  // the Neko core implementation has an attribute "r" ...kinda iffy, but w/e
  @:access(EReg.r)
  public static function getUnknown():Dynamic {
    return ~/regex/.r;
  }

  public static function describe(d:spaceCadet.Description) {
    d.describe("Inspect", function(d) {
      d.describe("on null", function(d) {
        d.it('inspects to "null"', function(a) {
          a.eq("null", inspect(null));
        });
      });

      d.describe("on a Bool", function(d) {
        d.it('true -> "true"', function(a) {
          a.eq("true", inspect(true));
        });
        d.it('false -> "false"', function(a) {
          a.eq("false", inspect(false));
        });
      });

      d.describe("on an Int", function(d) {
        d.it("inspects to the literal", function(a) {
          a.eq("0", inspect(0));
          a.eq("1", inspect(1));
          a.eq("-1", inspect(-1));
          a.eq("1234567890", inspect(1234567890));
          a.eq("-1234567890", inspect(-1234567890));
        });
      });

      d.describe("on a Float", function(d) {
        d.it('appends .0 when there are no values to the RHS of the point', function(a) {
          a.eq("0.0", inspect(0.0));
          a.eq("0.0", inspect(.0));
          a.eq("1.0", inspect(1.0));
          a.eq("-1.0", inspect(-1.0));
        });

        d.it('displays normally when there are values to the RHS of the point', function(a) {
          a.eq('123.456', inspect(123.456));
          a.eq('-123.456', inspect(-123.456));
        });

        d.it('reverts to scientific notation when the float is sufficiently large', function(a) {
          a.eq('1e+50', inspect(1e+50));
          a.eq('1e+50', inspect(1e50));
          a.eq('1.23e+50', inspect(1.23e+50));
          a.eq('1.23e+50', inspect(1.23e50));
          a.eq('-1.23e+50', inspect(-1.23e50));
        });
      });

      d.describe("on String", function(d) {
        d.it("wraps strings in quotes and escapes them", function(a) {
          a.eq('"a\\bc"', inspect("a\x08c"));
        });
        d.it("escapes double quotes to avoid delimiter confusion", function(a) {
          a.eq("\"\\\"\"", inspect('"'));
        });
        d.it("escapes escapes -- you should be able to paste the result into a source file and get the un-inspected version", function(a) {
          a.eq("\"\\\\\"", inspect('\\'));
        });
      });

      d.describe("on an array", function(d) {
        d.it("wraps the array in brackets", function(a) {
          a.eq("[]", inspect([]));
        });
        d.it("inspects each element, separating them with commas", function(a) {
          a.eq('["a"]', inspect(["a"]));
          a.eq('["a", "b"]', inspect(["a", "b"]));
          a.eq('[["a"], ["b"]]', inspect([["a"], ["b"]]));
        });
      });

      d.describe("on unknown", function(d) {
        d.it('displays "Unknown(s)", where s is whatever Std.string returns', function(a) {
          a.eq("Unknown(#abstract)", inspect(getUnknown()));
        });
      });
    });
  }
}
