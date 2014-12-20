package ruby;

class TestWorld extends ruby.support.TestCase {
  function testStringLiterals() {
    var str = world.stringLiteral("abc");
    assertEquals("abc", str.value);
    assertEquals(world.stringClass, str.klass);
    assertInObjectSpace(str);
  }
}
