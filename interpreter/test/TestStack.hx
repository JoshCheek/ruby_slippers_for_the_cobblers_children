class TestStack extends haxe.unit.TestCase {
  function testStack() {
    var s = new Stack<String>();
    assertEquals(0, s.length);
    assertEquals(null, s.peek);
    assertTrue(s.isEmpty);

    assertEquals("a", s.push("a"));
    assertEquals(1,   s.length);
    assertEquals("a", s.peek);
    assertFalse(s.isEmpty);

    s.push("c");
    assertEquals(2,   s.length);
    assertEquals("c", s.peek);
    assertFalse(s.isEmpty);

    assertEquals("c", s.pop());
    assertEquals(1,   s.length);
    assertEquals("a", s.peek);
    assertFalse(s.isEmpty);

    assertEquals("x", s.push("x"));
    assertEquals("y", s.push("y"));
    assertEquals("z", s.push("z"));
    assertEquals(4,   s.length);

    assertEquals("z", s.pop());
    assertEquals("y", s.pop());
    assertEquals("x", s.pop());
    assertEquals(1,   s.length);

    assertEquals("a",  s.pop());
    assertEquals(0,    s.length);
    assertEquals(null, s.peek);
    assertTrue(s.isEmpty);
  }
}
