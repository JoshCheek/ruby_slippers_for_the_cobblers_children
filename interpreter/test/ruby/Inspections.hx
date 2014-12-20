package ruby;
import ruby.ds.objects.*;

class Inspections extends ruby.support.TestCase {
  function assertInspects(obj:RObject, expected:String, ?pos:haxe.PosInfos) {
    assertEquals(expected, rInspect(obj));
  }

  function testInspect() {
    assertInspects(world.stringLiteral("abc"), '"abc"');
  }
}
