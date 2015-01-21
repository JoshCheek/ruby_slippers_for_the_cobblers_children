package spaceCadet;

class SpaceCadetDesc {
  public static function describe(d:spaceCadet.SpaceCadet.Description) {
    d.describe('Space Cadet', function(d) {
      d.describe('running a test suite', function(d) {
        d.it('reports describe blocks', function(a) {
          a.pending();
        });
        d.it('reports specification blocks', function(a) {
          a.pending();
        });
        d.it('reports true assertions', function(a) {
          a.pending();
        });
        d.it('reports failed assertions', function(a) {
          a.pending();
        });
        d.it('ends the spec when it sees a failed assertion', function(a) {
          a.pending();
        });
        d.it('reports the specification as a child of the describe block', function(a) {
          a.pending();
        });
        d.it('reports describe blocks as children of their parent', function(a) {
          a.pending();
        });
      });

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
