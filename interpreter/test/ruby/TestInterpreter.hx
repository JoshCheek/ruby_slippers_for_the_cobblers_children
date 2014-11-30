package ruby;

import ruby.ds.objects.RString;
import ruby.ds.objects.RObject;
import ruby.ds.objects.RClass;

using ruby.LanguageGoBag;

class TestInterpreter extends haxe.unit.TestCase {
  // https://github.com/JoshCheek/ruby_object_model_viewer/tree/5204eb089329b387353da0c25016328c55fba369/haxe-testing-example
  //   simple example of a test suite
  //
  // http://api.haxe.org/haxe/unit/index.html
  //   test suite api
  //
  // http://api.haxe.org/
  //   language api

  private function forCode(rawCode:String):RubyInterpreter {
    var ast         = ParseRuby.fromCode(rawCode);
    var interpreter = new RubyInterpreter();
    interpreter.addCode(ast);
    return interpreter;
  }

  private function assertLooksKindaSimilar<T>(a: T, b:T, ?pos:haxe.PosInfos):Void {
    assertEquals(Std.string(a), Std.string(b), pos);
  }

  // we're ignoring fixnums and symbols for now
  public function testSpecialConstants() {
    var interpreter = forCode("nil\ntrue\nfalse\n");
    assertEquals(interpreter.rubyNil,   interpreter.drain());
    assertEquals(interpreter.rubyTrue,  interpreter.drain());
    assertEquals(interpreter.rubyFalse, interpreter.drain());
  }

  public function testItsCurrentExpressionIsNilByDefault() {
    var interpreter = new RubyInterpreter();
    assertEquals(interpreter.rubyNil, interpreter.currentExpression());
  }

  public function testItEvaluatesAStringLiteral() {
    var rbstr       = new RString("Josh");
    var interpreter = forCode('"Josh"');
    interpreter.drain();
    assertLooksKindaSimilar(interpreter.currentExpression(), rbstr);
  }

  private function rStrs(strs:Array<String>):Array<RString> {
    return strs.map(function(str) return new RString(str));
  }

  // ffs Array<Dynamic> ...I'm giving it fucking RString, which *is* a RObject!
  private function assertDrains(interpreter, objects:Array<Dynamic>, ?pos:haxe.PosInfos) {
    var drained:Array<RObject> = interpreter.drainAll();
    for(pair in objects.zip(drained).iterator())
      assertLooksKindaSimilar(pair.l, pair.r, pos);
    assertEquals(objects.length, drained.length, pos);
  }

  public function testItSetsAndGetsLocalVariables() {
    var interpreter = forCode("var1 = 'b'
                               'c'
                               var1
                               var2 = 'd'
                               var1 = 'e'
                               var2
                               var1
                              ");
    assertDrains(interpreter, rStrs(['b', 'b', 'c', 'b', 'd', 'd', 'e', 'e', 'd', 'e']));
  }

  public function testClasses() {
    var interpreter = forCode("
      class A
      end
    ");
    interpreter.drainAll();
    assertLooksKindaSimilar(interpreter.toplevelNamespace().getConstant("A"), new RClass("A"));
  }

  public function testInstanceMethods() {
    var interpreter = forCode("
      # toplevel method is defined on Object
      def m
        true
      end
      m
    ");
    assertEquals(interpreter.drain(), interpreter.rubySymbol("m"));
    assertEquals(interpreter.rubyNil,         interpreter.drain()); // b/c the send doesn't result in a new currentValue
    assertEquals(interpreter.rubyTrue,        interpreter.drain());
    assertEquals(interpreter.rubyTrue,        interpreter.drain());
  }

  public function _testAacceptance1() {
    var interpreter = forCode('
      class User
        def initialize(name)
          self.name = name
        end

        def name
          @name
        end

        def name=(name)
          @name = name
        end
      end

      user = User.new("Josh")
      puts user.name'
    );

    interpreter.drainAll();

    // // the code successfully printed
    // // ... eventually switch to `assert_equal "Josh", stdout.string`
    // assertEquals("Josh\n", interpreter.printedInternally());

    // // it defined the class
    // var userClass = interpreter.lookupClass('User');
    // assertEquals('User', userClass.name);
    // assertEquals('[initialize,name,name=]', Std.string(userClass.instanceMethods));

    // // it is tracking the instance
    // assertEquals(1, interpreter.eachObject(userClass).length);
  }
}
