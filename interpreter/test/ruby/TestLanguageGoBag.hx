package ruby;

using ruby.LanguageGoBag;
using Lambda;

class TestLanguageGoBag extends ruby.support.TestCase {
  function testZip() {
    // both empty
    assertLooksKindaSimilar([], [].zip([]).array());

    // left is empty
    assertLooksKindaSimilar([], [].zip([1]).array());

    // right is empty
    assertLooksKindaSimilar([], [1].zip([]).array());

    // neither empty
    assertLooksKindaSimilar([{l: "a", r: 1}, {l: "b", r: 2}],
                            ["a", "b"].zip([1, 2]).array()
                           );

    // neither empty, different lengths
    assertLooksKindaSimilar([{l: "a", r: 1}], ["a"].zip([1, 2]).array());
  }

  function testFromEnd() {
    // empty
    var pre = [];
    var post = [];
    for(e in pre.fromEnd()) post.push(e);
    assertLooksKindaSimilar([], pre);
    assertLooksKindaSimilar([], post);

    // a few items
    var pre  = ['a', 'b', 'c'];
    var post = [];
    for(e in pre.fromEnd()) post.push(e);
    assertLooksKindaSimilar(['a', 'b', 'c'], pre);  // no change
    assertLooksKindaSimilar(['c', 'b', 'a'], post); // reversed

    // compatible with Lambda
    var pre = [5, 4, 3];
    var post = pre.fromEnd().map(function(n) return n*2);
    var expected = new List();
    expected.add(6);
    expected.add(8);
    expected.add(10);
    assertLooksKindaSimilar(expected, post);
  }
}
