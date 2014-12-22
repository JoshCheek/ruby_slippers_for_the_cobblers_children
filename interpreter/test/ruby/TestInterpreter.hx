package ruby;

import ruby.ds.objects.RString;
import ruby.ds.objects.RObject;
import ruby.ds.objects.RClass;
import ruby.ds.InternalMap;
import ruby.ds.Errors;

using ruby.LanguageGoBag;

class TestInterpreter extends ruby.support.TestCase {
  function testInterpretsSingleExpression() {
    pushCode("true");
    rAssertEq(world.rubyTrue, interpreter.nextExpression());
  }

  function testEvaluatingExpressionsUpdatesTheCurrentExpression() {
    pushCode("true");
    rAssertEq(world.rubyNil, world.currentExpression);
    interpreter.nextExpression();
    rAssertEq(world.rubyTrue, world.currentExpression);
  }

  function testInterpretsMultipleExpressions() {
    pushCode("nil\ntrue\nfalse");
    rAssertEq(world.rubyNil, interpreter.nextExpression());
    rAssertEq(world.rubyTrue, interpreter.nextExpression());
  }

  function testThrowsIfAskedForExpressionAfterFinished() {
    assertThrows(function() interpreter.nextExpression());

    pushCode("true");
    interpreter.nextExpression();
    assertThrows(function() interpreter.nextExpression());
  }

  // we're ignoring fixnums and symbols for now
  function testSpecialConstants() {
    pushCode("nil\ntrue\nfalse\n");
    assertNextExpressions([world.rubyNil, world.rubyTrue, world.rubyFalse]);
  }

  function testItEvaluatesAStringLiteral() {
    pushCode('"Josh"');
    rAssertEq(world.stringLiteral("Josh"), interpreter.nextExpression());
  }

  function testItSetsAndGetsLocalVariables() {
    pushCode("var1 = 'b'
             'c'
             var1
             var2 = 'd'
             var1 = 'e'
             var2
             var1
             ");
    var rStrs = ['b', 'b', 'c', 'b', 'd', 'd', 'e', 'e', 'd', 'e'].map(function(str) {
      var obj:RObject = world.stringLiteral(str); // *sigh*
      return obj;
    });
    assertNextExpressions(rStrs);
  }

  // function testMoarLocalVars() {
  //   pushCode("a = 'x'; b = a");
  //   interpreter.nextExpression();
  //   interpreter.nextExpression();
  //   var a = world.getLocal('a');
  //   interpreter.nextExpression();
  //   // TODO refute local var 'b' exists... or actually, with how Ruby works, this is nil at this point
  //   interpreter.nextExpression();
  //   var b = world.getLocal('b');
  //   assertEquals(a, b); // a and b have ref to same obj
  // }

  // //TODO: local vars with more than 1 binding


  // public function testToplevelConstantLookup() {
  //   pushCode("Object; String");
  //   rAssertEq(world.objectClass, interpreter.nextExpression());
  //   rAssertEq(world.stringClass, interpreter.nextExpression());
  // }

  // public function testClassDefinition() {
  //   pushCode("class A; end");
  //   trace("\033[31mPRE\033[0m");
  //   assertNull(world.toplevelNamespace.constants['A']);
  //   trace("\033[31mMIDDLE\033[0m");
  //   interpreter.evaluateAll();
  //   trace("\033[31mPOST\033[0m");
  //   // assertEquals('A', rInspect(world.toplevelNamespace.constants['A']));
  //   // TODO: Test non-toplevel
  // }

  // TODO: Test reopening the class

  // public function _testMessageSending() {
  //   pushCode("'abc'.class; :abc.class");
  //   interpreter.nextExpression();
  //   rAssertEq(world.stringClass, interpreter.nextExpression());
  // }

  // public function _testInstantiation() {
  //   pushCode("
  //     class A
  //     end
  //     BasicObject.new
  //     String.new
  //     A.new
  //   ");
  //   interpreter.evaluateAll();
  //   var os  = world.objectSpace;
  //   var a   = os[os.length - 1];
  //   var str = os[os.length - 2];
  //   var bo  = os[os.length - 3];
  //   rAssertEq(world.toplevelNamespace.constants['A'],   a.klass);
  //   rAssertEq(world.stringClass,      str.klass);
  //   rAssertEq(world.basicObjectClass, bo.klass);
  //   // Instantiation
  //   //   new
  //   //     returns a RObject with klass set to self
  //   //     initializes the object, passing the params
  //   //   allocate
  //   //     makes an RObject with the klass set
  //   //   // Object#initialize
  //   //   //   takes no params, does nothing
  // }


  /* ----- OLD TESTS THAT NEED TO BE REIMPLEMENTED -----

  One above does not create its own classes
  public function testInstantiation() {
    pushCode("
      class A
      end
      A.new
      Object.new
    ");
    // NOTE: could be nil b/c A's body is empty
    interpreter.nextExpression();
    interpreter.nextExpression();
    interpreter.nextExpression();
    var a      = interpreter.nextExpression();
    var aClass = world.toplevelNamespace.constants['A'];
    assertEquals(aClass, a.klass);
    var obj    = interpreter.nextExpression();
    assertEquals(world.objectClass, obj.klass);

    // Instantiation
    //   new
    //     returns a RObject with klass set to self
    //     initializes the object, passing the params
    //   allocate
    //     makes an RObject with the klass set
    //   // Object#initialize
    //   //   takes no params, does nothing

  }




  // line mode?
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
