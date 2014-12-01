package ruby;

import ruby.ds.objects.RString;
import ruby.ds.objects.RObject;
import ruby.ds.objects.RClass;
import ruby.ds.InternalMap;

using ruby.LanguageGoBag;
using ruby.WorldWorker;

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
    var interpreter = RubyInterpreter.fromBootstrap();
    interpreter.addCode(ast);
    return interpreter;
  }

  private function assertLooksKindaSimilar<T>(a: T, b:T, ?pos:haxe.PosInfos):Void {
    assertEquals(Std.string(a), Std.string(b), pos);
  }

  // we're ignoring fixnums and symbols for now
  public function testSpecialConstants() {
    var interpreter = forCode("nil\ntrue\nfalse\n");
    var world       = interpreter.world;
    assertEquals(world.rubyNil,   interpreter.drain());
    assertEquals(world.rubyTrue,  interpreter.drain());
    assertEquals(world.rubyFalse, interpreter.drain());
  }

  // maybe this goes on a world bootstrap test?
  public function testItsCurrentExpressionIsNilByDefault() {
    var interpreter = RubyInterpreter.fromBootstrap();
    var world       = interpreter.world;
    assertEquals(world.rubyNil, interpreter.currentExpression());
  }

  public function testItEvaluatesAStringLiteral() {
    var interpreter = forCode('"Josh"');
    var world       = interpreter.world;
    var rbstr:RString = {
      klass: world.objectClass,
      ivars: new InternalMap(),
      value: "Josh",
    }
    interpreter.drain();
    assertLooksKindaSimilar(interpreter.currentExpression(), rbstr);
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
    var world = interpreter.world;
    var rStrs = ['b', 'b', 'c', 'b', 'd', 'd', 'e', 'e', 'd', 'e'].map(function(str) {
      var rString = {klass: world.objectClass, ivars: new InternalMap(), value: str}
      return rString;
    });
    assertDrains(interpreter, rStrs);
  }

  public function testClasses() {
    var interpreter = forCode("
      class A
      end
    ");
    interpreter.drainAll();
    var world = interpreter.world;

    var expected:RClass = {
      name:       "A",
      klass:      world.klassClass,
      ivars:      new InternalMap(),
      imeths:     new InternalMap(),
      constants:  new InternalMap(),
      superclass: world.objectClass,
    };

    var actual = interpreter.getConstant(interpreter.toplevelNamespace(), "A");
    assertLooksKindaSimilar(actual, expected);
  }

  public function testInstanceMethods() {
    var interpreter = forCode("
      # toplevel method is defined on Object
      def m
        true
      end
      m
    ");
    var world = interpreter.world;
    assertEquals(interpreter.drain(), interpreter.intern("m"));
    assertEquals(world.rubyNil,       interpreter.drain()); // b/c the send doesn't result in a new currentValue
    assertEquals(world.rubyTrue,      interpreter.drain());
    assertEquals(world.rubyTrue,      interpreter.drain());
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
    // assertEquals('[initialize,name,name=]', Std.string(userClass.imeths));

    // // it is tracking the instance
    // assertEquals(1, interpreter.eachObject(userClass).length);
  }
}
