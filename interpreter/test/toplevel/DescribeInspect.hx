package toplevel;

class DescribeInspect {
  public static function inspect(str) {
    return Inspect.call(str);
  }
  public static function describe(d:spaceCadet.Description) {
    d.describe("Inspect", function(d) {
      d.describe("on String", function(d) {
        d.it("wraps strings in quotes and escapes them", function(a) {
          a.eq('"a\\bc"', inspect("a\x08c"));
        });
        d.it("escapes double quotes to avoid delimiter confusion", function(a) {
          a.eq("\"\\\"\"", inspect('"'));
        });
      });
    });
  }
}
