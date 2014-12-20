package ruby;

import ruby.ds.objects.RString;
import ruby.ds.objects.RObject;
import ruby.ds.objects.RClass;
import ruby.ds.InternalMap;
import ruby.ds.Errors;

using ruby.LanguageGoBag;
using ruby.WorldWorker;

class TestInterpreter extends ruby.support.TestCase {
  public function testItsCurrentExpressionIsNilByDefault() {
    assertEquals(world.rubyNil, interpreter.currentExpression());
  }

  public function testInterpretsSingleExpression() {
    addCode("true");
    rAssertEq(world.rubyTrue, interpreter.nextExpression());
  }

  public function testInterpretsMultipleExpressions() {
    addCode("nil\ntrue");
    rAssertEq(world.rubyNil, interpreter.nextExpression());
    rAssertEq(world.rubyTrue, interpreter.nextExpression());
  }

  public function testThrowsIfAskedForExpressionAfterFinished() {
    assertThrows(function() interpreter.nextExpression());

    addCode("true");
    interpreter.nextExpression();
    assertThrows(function() interpreter.nextExpression());
  }

  // we're ignoring fixnums and symbols for now
  public function testSpecialConstants() {
    addCode("nil\ntrue\nfalse\n");
    rAssertEq(world.rubyNil,   interpreter.nextExpression());
    rAssertEq(world.rubyTrue,  interpreter.nextExpression());
    rAssertEq(world.rubyFalse, interpreter.nextExpression());
  }

  /* ----- OLD TESTS THAT NEED TO BE REIMPLEMENTED -----
  // maybe this goes on a world bootstrap test?

  public function testItEvaluatesAStringLiteral() {
    var interpreter = forCode('"Josh"');
    var world       = interpreter.world;
    var rbstr:RString = {
      klass: world.objectClass,
      ivars: new InternalMap(),
      value: "Josh",
    }
    interpreter.drainExpression();
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

  public function testMoarLocalVars() {
    var interpreter = forCode("a = 'x'; b = a; b");
    var a = interpreter.drainExpression();
    assertEquals(a, interpreter.drainExpression()); // b = a
    assertEquals(a, interpreter.drainExpression()); // b
  }

  // line mode?
  public function testInstantiation() {
    var interpreter = forCode("
      class A
      end
      A.new
      Object.new
    ");
    // NOTE: could be nil b/c A's body is empty
    interpreter.drainExpression();
    interpreter.drainExpression();
    interpreter.drainExpression();
    var a      = interpreter.drainExpression();
    var aClass = interpreter.getConstant(interpreter.toplevelNamespace(), "A");
    assertEquals(aClass, a.klass);

    var obj    = interpreter.drainExpression();
    assertEquals(obj.klass, interpreter.world.objectClass);

    // Instantiation
    //   new
    //     returns a RObject with klass set to self
    //     initializes the object, passing the params
    //   allocate
    //     makes an RObject with the klass set
    //   // Object#initialize
    //   //   takes no params, does nothing

  }


  public function _testSelfWorks() {
    var interpreter = forCode("
        TODO!
    ");
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
    assertEquals(interpreter.drainExpression(), interpreter.intern("m"));
    interpreter.drainExpression();
    assertEquals(world.rubyNil,                 interpreter.drainExpression()); // b/c the send doesn't result in a new currentValue
    assertEquals(world.rubyTrue,                interpreter.drainExpression());
    assertEquals(world.rubyTrue,                interpreter.drainExpression());
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
  */
}
