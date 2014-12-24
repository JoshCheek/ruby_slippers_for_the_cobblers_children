package ruby;

import ruby.ds.Objects;
import ruby.ds.InternalMap;
import ruby.ds.Errors;

using ruby.LanguageGoBag;

class TestInterpreter extends ruby.support.TestCase {
  function testItsCurrentExpressionIsNilByDefault() {
    assertEquals(world.rubyNil, interpreter.currentExpression);
  }

  function testInterpretsSingleExpression() {
    pushCode("true");
    rAssertEq(world.rubyTrue, interpreter.nextExpression());
  }

  function testEvaluatingExpressionsUpdatesTheCurrentExpression() {
    pushCode("true");
    rAssertEq(world.rubyNil, interpreter.currentExpression);
    interpreter.nextExpression();
    rAssertEq(world.rubyTrue, interpreter.currentExpression);
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
    pushCode("nil\ntrue\nfalse\nself");
    assertNextExpressions([world.rubyNil, world.rubyTrue, world.rubyFalse, world.main]);
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

  function testMoarLocalVars() {
    pushCode("a = 'x'; b = a");
    interpreter.nextExpression();
    interpreter.nextExpression();
    var a = interpreter.getLocal('a');
    interpreter.nextExpression();
    // TODO: rAssertNil(world.getLocal('b'));
    interpreter.nextExpression();
    var b = interpreter.getLocal('b');
    assertEquals(a, b); // a and b have ref to same obj
  }

  //TODO: local vars with more than 1 binding on the stack


  public function testToplevelConstantLookup() {
    pushCode("Object; String");
    rAssertEq(world.objectClass, interpreter.nextExpression());
    rAssertEq(world.stringClass, interpreter.nextExpression());
  }

  public function testClassDefinition() {
    pushCode("class A; end");
    assertNull(world.toplevelNamespace.constants['A']);
    interpreter.evaluateAll();
    var aClass = world.toplevelNamespace.constants['A'];
    assertEquals('A', rInspect(aClass));
    assertEquals(world.classClass,  aClass.klass);
    assertEquals(world.objectClass, world.castClass(aClass).superclass);
    // TODO: Test non-toplevel
  }

  // TODO: Test reopening the class

  public function testMessageSending() {
    pushCode("'abc'.class; nil.class");
    assertNextExpressions([
      world.stringLiteral('abc'),
      world.stringClass,
      world.rubyNil,
      world.rubyNil.klass,
      world.rubyNil.klass,
    ]);
  }

  // TODO: Test method definition

  public function testInstantiation() {
    pushCode("class A
              end
              BasicObject.new
              String.new
              A.new
            ");
    interpreter.evaluateAll();
    var os  = world.objectSpace;
    // This is precarious: could fail if new creates additional objects :/
    var a   = os[os.length - 1];
    var str = os[os.length - 2];
    var bo  = os[os.length - 3];

    assertEquals(world.toplevelNamespace.constants['A'], a.klass);
    assertEquals(world.stringClass,                      str.klass);
    assertEquals(world.basicObjectClass,                 bo.klass);
    // Instantiation
    //   new
    //     returns a RObject with klass set to self
    //     initializes the object, passing the params
    //   allocate
    //     makes an RObject with the klass set
    //   // Object#initialize
    //   //   takes no params, does nothing
  }

  /* ----- OLD TESTS THAT NEED TO BE REIMPLEMENTED -----

  // line mode?
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
