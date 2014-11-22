class TestFoo extends haxe.unit.TestCase {
  var str: String;

  public function testBasic() {
    assertEquals("A", "A");
  }


  override public function setup() {
    str = "foo";
  }

  public function testSetup() {
    assertEquals("foo", str);
  }

  // With complex objects it can be difficult to generate
  // expected values to compare to the actual ones.
  // It can also be a problem that assertEquals doesn't do a deep comparison.
  // One way around these issues is to use a string as the expected value and
  // compare it to the actual value converted to a string using Std.string().
  // Below is a trivial example using an array.
  public function testArray() {
    var actual = [1,2,3];
    assertEquals("[1,2,3]", Std.string(actual));

    // e.g. this fails... not really clear to me why, though
    // as I don't know how arrays or equality are represented in this language
    //
    // assertEquals([1,2,3], [1,2,3]);
  }
}
