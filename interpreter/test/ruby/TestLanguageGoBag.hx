package ruby;

using ruby.LanguageGoBag;
using Lambda;

class TestLanguageGoBag extends haxe.unit.TestCase {
  private function assertLooksKindaSimilar<T>(a: T, b:T):Void {
    assertEquals(Std.string(a), Std.string(b));
  }

  public function testZip() {
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

  public function testReverseIterator() {
    // empty
    var pre = [];
    var post = [];
    for(e in pre.reverseIterator()) post.push(e);
    assertLooksKindaSimilar([], pre);
    assertLooksKindaSimilar([], post);

    // a few items
    var pre  = ['a', 'b', 'c'];
    var post = [];
    for(e in pre.reverseIterator()) post.push(e);
    assertLooksKindaSimilar(['a', 'b', 'c'], pre);  // no change
    assertLooksKindaSimilar(['c', 'b', 'a'], post); // reversed
  }
}
