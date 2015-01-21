package spaceCadet;
import spaceCadet.SpaceCadet;

class SpaceCadetDesc {
  public static function describe(d:Description) {
    d.describe('Space Cadet', function(d) {
      d.it('runs the specs and describe blcks in the order they were described in', function(a) {
        a.pending();
      });

      d.describe('before blocks', function(d) {
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
    });
  }
}
