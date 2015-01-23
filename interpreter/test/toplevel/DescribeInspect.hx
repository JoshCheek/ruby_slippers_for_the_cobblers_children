package toplevel;

class DescribeInspect {
  public static function inspect(str:Dynamic) {
    return Inspect.call(str);
  }
  public static function describe(d:spaceCadet.Description) {
    d.describe("Inspect", function(d) {
      d.describe("on a Bool", function(d) {
        d.it('true -> "true"', function(a) {
          a.eq("true", inspect(true));
        });
        d.it('false -> "false"', function(a) {
          a.eq("false", inspect(false));
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
    });
  }
}
