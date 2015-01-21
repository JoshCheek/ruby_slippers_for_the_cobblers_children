package spaceCadet;
import spaceCadet.SpaceCadet;

class DescribeBeforeBlocks {
  public static function describe(d:Description) {
    d.describe('Space Cadet before blocks', function(d) {
      d.it('runs before blocks prior to each test', function(a) {
        a.pending();
      });
      d.it('runs before blcoks in the order they were defined in', function(a) {
        a.pending();
      });
      d.it('runs parent before blocks prior to children before blocks', function(a) {
        a.pending();
      });
      d.it('allows before blocks to make assertions', function(a) {
        a.pending();
      });
    });
  };
}
