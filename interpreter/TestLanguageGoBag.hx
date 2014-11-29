using LanguageGoBag;
using Lambda;

class TestLanguageGoBag extends haxe.unit.TestCase {
  private function assertLooksKindaSimilar<T>(a: T, b:T):Void {
    assertEquals(Std.string(a), Std.string(b));
  }

  // it returns an iterable over the left and right iterables
  // where it hasNext while left and right both hasNext
  public function testCases() {
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
}
