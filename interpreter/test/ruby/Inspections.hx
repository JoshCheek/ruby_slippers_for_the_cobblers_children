package ruby;
import ruby.ds.objects.*;

class Inspections extends haxe.unit.TestCase {
  public function rInspect(obj:RObject):String {
    var klass = switch(obj) {
      case {klass: k}: k;
      case _: throw "no kass here: " + obj;
    }

    if(klass.name == 'Class') {
      var tmp:Dynamic = obj;
      var objClass:RClass = tmp;
      return objClass.name;
    } else if(klass.name == 'Object') {
      return "#<" + obj.klass.name + ">";
    } else {
      return "" + obj; // :D
    }
  }

  public function rEqual(l:RObject, r:RObject) {
    return rInspect(l) == rInspect(r);
  }

  public function rAssertEq(expected:RObject, actual:RObject, ?c:haxe.PosInfos) : Void {
		currentTest.done = true;
		if (rEqual(expected, actual)) return;
    currentTest.success = false;
    currentTest.error   = "expected '"  + rInspect(expected) +
                          "' but was '" + rInspect(actual)   + "'";
    currentTest.posInfos = c;
    throw currentTest;
  }

  public function testSpecialConstants() {
    var world = WorldDomination.bootstrap();
    rAssertEq(world.rubyNil, world.rubyNil);
  }
}
