package ruby;

import ruby.ds.objects.RObject;

class TestSupport extends ruby.support.TestCase {
  function assertInspects(obj:RObject, expected:String, ?pos:haxe.PosInfos) {
    assertEquals(expected, rInspect(obj));
  }
  function testInspect() {
    assertInspects(world.stringLiteral("abc"), '"abc"');
  }

  function _testAssertNextExpressionsWithFewer() {
    pushCode("true; nil; true");
    assertNextExpressions([
      world.rubyTrue,
      world.rubyNil,
      world.rubyTrue,
    ]);
  }

  function _testAssertNextExpressionsWithExact() {
    pushCode("true; nil; true");
    assertNextExpressions([
      world.rubyTrue,
      world.rubyNil,
      world.rubyTrue,
      world.rubyTrue, // list evaluates to last expression in it
    ]);
  }

  function testAssertNull() {
    assertNull(null);
    try assertNull(1) catch(x:haxe.unit.TestStatus) return;
    throw("Should have raised when it didn't get null!");
  }
}
