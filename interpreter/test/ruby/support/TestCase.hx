package ruby.support;
import ruby.WorldDomination;
import ruby.Interpreter;
import ruby.ds.World;
import ruby.ds.objects.*;

class TestCase extends haxe.unit.TestCase {
  public var world:World;
  public var interpreter:Interpreter;

  public function new() {
    super();
    world       = ruby.WorldDomination.bootstrap();
    interpreter = new Interpreter(world);
  }

  public function rInspect(obj:RObject):String {
    var klass = switch(obj) {
      case {klass: k}: k;
      case _: throw "no kass here: " + obj;
    }

    if(klass.name == 'Class') {
      var tmp:Dynamic = obj;
      var objClass:RClass = tmp;
      return objClass.name;
    } else {
      return "#<" + obj.klass.name + ">";
    // } else {
    //   return "" + obj; // :D
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

  private function assertLooksKindaSimilar<T>(a: T, b:T, ?pos:haxe.PosInfos):Void {
    assertEquals(Std.string(a), Std.string(b), pos);
  }

  public function addCode(rawCode:String) {
    var ast = ParseRuby.fromCode(rawCode);
    world.currentEvaluation = Unevaluated(ast); // TODO: what if there is a current evaluation underway?
  }

}
