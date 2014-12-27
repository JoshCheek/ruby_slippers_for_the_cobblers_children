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

  public function testClassAndMethodDefinition() {
    pushCode("
        # def in a class
        class A
          def ameth; end
        end

        # toplevel def with body
        def ometh
          true
        end
        ometh

        # def without a body
        def nobody_meth; end
        nobody_meth

        # def with arguments
        def meth_with_args(req, *rest)
        end
        # TODO: invoke it
    ");

    assertNull(world.toplevelNamespace.constants['A']);
    assertNextExpressions([
      world.intern("ameth"), // ends def
      world.intern("ameth"), // ends class

      world.intern("ometh"),
      world.rubyTrue,
      world.rubyTrue,

      world.intern("nobody_meth"),
      world.rubyNil,

      world.intern("meth_with_args"),
    ]);

    // class definition
    var aClass = world.castClass(world.toplevelNamespace.constants['A']);
    assertEquals(world.classClass,  aClass.klass);       // klass
    assertTrue(aClass.ivars.empty());                    // ivars
    assertEquals('A', rInspect(aClass));                 // name
    assertEquals(world.objectClass, aClass.superclass);  // superclass
    assertTrue(aClass.constants.empty());                // ivars

    // TODO: assert the methods that should exist on it

    // A#ameth
    var ameth = aClass.imeths['ameth'];
    // FIXME: Assert klass (should be Method, but haven't made that one yet, so it's Object)
    assertEquals("ameth", ameth.name);
    assertEquals(0, ameth.args.length);
    assertLooksKindaSimilar(ameth.body, Ruby(Default));

    // Object#ometh
    var ometh = world.objectClass.imeths['ometh'];
    assertEquals("ometh", ometh.name);
    assertEquals(0, ometh.args.length);
    assertLooksKindaSimilar(ometh.body, Ruby(True));

    // Object#meth_with_args
    var methWithArgs = world.objectClass.imeths['meth_with_args'];
    assertLooksKindaSimilar(
      methWithArgs.args,
      [Required("req"), Rest("rest")]
    );
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

  public function testAacceptance1() {
    pushCode('
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

    interpreter.evaluateAll();

    var userClassObj:Dynamic = world.toplevelNamespace.constants['User'];
    var userClass:RClass     = userClassObj;

    assertTrue(null != userClass.imeths['initialize']);
    assertTrue(null != userClass.imeths['name']);
    assertTrue(null != userClass.imeths['name=']);

    // the code successfully printed
    // ... eventually switch to `assert_equal "Josh", stdout.string`
    assertLooksKindaSimilar(["Josh\n"], world.printedToStdout);

    // // it is tracking the instance
    // var users = world.eachObject(userClass);
    // assertEquals(1, users.length);
    // var user = users[0];

    // // the instance has the ivar set
    // assertEquals(world.stringClass, user.ivars['@name'].klass);
    // var nameD:Dynamic = user.ivars['@name'];
    // var name:RString  = nameD;
    // assertEquals("Josh", name.value);
  }
}
