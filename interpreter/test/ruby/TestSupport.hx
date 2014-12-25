package ruby;

import ruby.ds.Objects;

class TestSupport extends ruby.support.TestCase {
  function assertInspects(obj:RObject, expected:String, ?pos:haxe.PosInfos) {
    assertEquals(expected, rInspect(obj));
  }
  function testInspect() {
    assertInspects(world.stringLiteral("abc"), '"abc"');
  }

  function testRAssertEq() {
    rAssertEq(world.intern("abc"), world.intern("abc"));

    var fails = true;
    try rAssertEq(world.intern("abc"), world.intern("xyz"))
    catch (e:haxe.unit.TestStatus) fails = false;
    assertFalse(fails);
  }

  function testAssertNextExpressions() {
    var ast = ParseRuby.fromCode("true; nil; true");
    // fewer
    interpreter.pushCode(ast);
    assertNextExpressions([world.rubyTrue, world.rubyNil]);

    // exact (last true is b/c the list itself evaluates to the last expression in it)
    interpreter.pushCode(ast);
    assertNextExpressions([world.rubyTrue, world.rubyNil, world.rubyTrue, world.rubyTrue]);

    // more
    interpreter.pushCode(ast);
    try assertNextExpressions([
          world.rubyTrue,
          world.rubyNil,
          world.rubyTrue,
          world.rubyTrue,
          world.rubyTrue,
        ])
    catch(x:haxe.unit.TestStatus) return;
    throw("Should have raised because we expected more expressions");
  }

  function testAssertNull() {
    assertNull(null);
    try assertNull(1) catch(x:haxe.unit.TestStatus) return;
    throw("Should have raised when it didn't get null!");
  }
}
