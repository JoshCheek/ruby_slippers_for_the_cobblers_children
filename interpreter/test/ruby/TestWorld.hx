package ruby;

class TestWorld extends ruby.support.TestCase {
  function testStringLiterals() {
    var str = world.stringLiteral("abc");
    assertEquals("abc", str.value);
    assertEquals(world.stringClass, str.klass);
    assertInObjectSpace(str);
  }

  // FIXME: IMPLEMENT THIS
  // function testStackAndBindings() {
  //   assertEquals(world.toplevelBinding, world.currentBinding);
  //   var newBnd = world.bindingFor(world.rubyNil);
  //   refuteEquals(newBnd, world.toplevelBinding);
  //   world.pushStack(newBnd);
  //   assertEquals(newBnd, world.currentBinding);
  //   world.popStack();
  //   assertEquals(world.toplevelBinding, world.currentBinding);
  // }
}
