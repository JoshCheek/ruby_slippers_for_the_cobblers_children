package ruby;

using ruby.LanguageGoBag;
using Lambda;

class LanguageGoBagSpec {
  public static function describe(d:spaceCadet.Description) {
    d.example('zip', function(a) {
      // both empty
      a.streq([], [].zip([]).array());

      // left is empty
      a.streq([], [].zip([1]).array());

      // right is empty
      a.streq([], [1].zip([]).array());

      // neither empty
      a.streq([{l: "a", r: 1}, {l: "b", r: 2}],
                              ["a", "b"].zip([1, 2]).array()
                             );

      // neither empty, different lengths
      a.streq([{l: "a", r: 1}], ["a"].zip([1, 2]).array());
    });

    d.example('fromEnd', function(a) {
      // empty
      var pre = [];
      var post = [];
      for(e in pre.fromEnd()) post.push(e);
      a.streq([], pre);
      a.streq([], post);

      // a few items
      var pre  = ['a', 'b', 'c'];
      var post = [];
      for(e in pre.fromEnd()) post.push(e);
      a.streq(['a', 'b', 'c'], pre);  // no change
      a.streq(['c', 'b', 'a'], post); // reversed

      // compatible with Lambda
      var pre = [5, 4, 3];
      var post = pre.fromEnd().map(function(n) return n*2);
      var expected = new List();
      expected.add(6);
      expected.add(8);
      expected.add(10);
      a.streq(expected, post);
    });
  }
}
