package ruby2;

// import ruby2.Objects;
import ruby2.Interpreter;
import ruby2.World;
// import ruby2.InternalMap;
// import ruby2.Errors;

using ruby2.LanguageGoBag;

class InterpreterSpec {
  public static function describe(d:spaceCadet.Description) {
    var world       : World;
    var interpreter : Interpreter;

    d.before(function(a) {
      world       = World.bootstrap();
      interpreter = new Interpreter(world);
    });

    function pushCode(rawCode:String):Void {
      var ast = Parse.fromString(rawCode);
      interpreter.pushAst(ast);
    }

    function assertThrows(a:spaceCadet.Asserter, fn) {
      var caught = false;
      try { fn(); }
      catch(e:Errors) { caught = true; }
      a.eq(true, caught);
    }


    d.describe('ruby2.Interpreter', function(d) {
      d.it('blows up when given no code', function(a) {
        assertThrows(a, function() interpreter.pushAst(null));
      });

      // d.it('currentExpression is nil by default', function(a) {
      //   a.eq(world.rubyNil, interpreter.currentExpression);
      // });

      // d.it('interprets a single expression', function(a) {
      //   pushCode("true");
      //   a.eq(world.rubyTrue, interpreter.nextExpression());
      // });

      // d.specify('evaluating an expression updates the current expression', function(a) {
      //   pushCode("true");
      //   a.eq(world.rubyNil, interpreter.currentExpression);
      //   interpreter.nextExpression();
      //   a.eq(world.rubyTrue, interpreter.currentExpression);
      // });

      // d.it('interprets multiple expressions', function(a) {
      //   pushCode("nil\ntrue\nfalse");
      //   a.eq(world.rubyNil, interpreter.nextExpression());
      //   a.eq(world.rubyTrue, interpreter.nextExpression());
      // });

      // d.it('throws if asked for expressions after being finished', function(a) {
      //   assertThrows(a, function() interpreter.nextExpression());

      //   pushCode("true");
      //   interpreter.nextExpression();
      //   assertThrows(a, function() interpreter.nextExpression());
      // });

      // function assertNextExpressions(a:spaceCadet.Asserter, expected:Array<RObject>, ?c:haxe.PosInfos) {
      //   var actual:Array<RObject> = [];
      //   while(interpreter.isInProgress)
      //     actual.push(interpreter.nextExpression());
      //   for(pair in expected.zip(actual)) a.streq(pair.l, pair.r);
      //   if(expected.length <= actual.length) return;
      //   a.eqm(1,2, 'Expected at least ${expected.length} expressions, but there were ${actual.length}', c);
      // }

      // // we're ignoring fixnums and symbols for now
      // d.it('evalutes special constants', function(a) {
      //   pushCode("nil\ntrue\nfalse\nself");
      //   assertNextExpressions(a, [
      //     world.rubyNil,
      //     world.rubyTrue,
      //     world.rubyFalse,
      //     world.main
      //   ]);
      // });

      // d.it('evaluates a string literal', function(a) {
      //   pushCode('"Josh"');
      //   a.streq(interpreter.nextExpression(), world.stringLiteral("Josh"));
      // });

      // d.it('sets and gets local variables', function(a) {
      //   pushCode("var1 = 'b'
      //            'c'
      //            var1
      //            var2 = 'd'
      //            var1 = 'e'
      //            var2
      //            var1
      //            ");
      //   var rStrs = ['b', 'b', 'c', 'b', 'd', 'd', 'e', 'e', 'd', 'e'].map(function(str) {
      //     var obj:RObject = world.stringLiteral(str); // *sigh*
      //     return obj;
      //   });
      //   assertNextExpressions(a, rStrs);
      // });

      // d.example('more local vars', function(a) {
      //   pushCode("a = 'x'; b = a");
      //   interpreter.nextExpression();
      //   interpreter.nextExpression();
      //   var vara = interpreter.getLocal('a');
      //   interpreter.nextExpression();
      //   // TODO: rAssertNil(world.getLocal('b'));
      //   interpreter.nextExpression();
      //   var varb = interpreter.getLocal('b');
      //   a.eq(vara, varb); // a and b have ref to same obj
      // });

      // // //TODO: local vars with more than 1 binding on the stack

      // d.it('evaluates toplevel constant lookup', function(a) {
      //   pushCode("Object; String");
      //   a.eq(interpreter.nextExpression(), world.objectClass);
      //   a.eq(interpreter.nextExpression(), world.stringClass);
      // });

      // d.it('evaluates class and method definitions', function(a) {
      //   pushCode("
      //       # def in a class
      //       class A
      //         def ameth; end
      //       end

      //       # toplevel def with body
      //       def ometh
      //         true
      //       end
      //       ometh

      //       # def without a body
      //       def nobody_meth; end
      //       nobody_meth

      //       # def with arguments
      //       def meth_with_args(req, *rest)
      //       end
      //       # TODO: invoke it
      //   ");

      //   a.eq(null, world.toplevelNamespace.constants['A']);
      //   assertNextExpressions(a, [
      //     world.intern("ameth"), // ends def
      //     world.intern("ameth"), // ends class

      //     world.intern("ometh"),
      //     world.rubyTrue,
      //     world.rubyTrue,

      //     world.intern("nobody_meth"),
      //     world.rubyNil,

      //     world.intern("meth_with_args"),
      //   ]);

      //   // class definition
      //   var aClass = world.castClass(world.toplevelNamespace.constants['A']);
      //   a.eq(world.classClass,  aClass.klass);       // klass
      //   a.eq(true, aClass.ivars.empty());            // ivars
      //   a.eq('A', ruby2.World.sinspect(aClass));      // name
      //   a.eq(world.objectClass, aClass.superclass);  // superclass
      //   a.eq(true, aClass.constants.empty());        // ivars

      //   // TODO: assert the methods that should exist on it

      //   // A#ameth
      //   var ameth = aClass.imeths['ameth'];
      //   // FIXME: Assert klass (should be Method, but haven't made that one yet, so it's Object)
      //   a.eq("ameth", ameth.name);
      //   a.eq(0, ameth.args.length);
      //   a.streq(ameth.body, Ruby(Default));

      //   // Object#ometh
      //   var ometh = world.objectClass.imeths['ometh'];
      //   a.eq("ometh", ometh.name);
      //   a.eq(0, ometh.args.length);
      //   a.streq(ometh.body, Ruby(True({begin:169, end:173})));

      //   // Object#meth_with_args
      //   var methWithArgs = world.objectClass.imeths['meth_with_args'];
      //   a.streq(methWithArgs.args, [Required("req"), Rest("rest")]);
      // });

      // // TODO: Test reopening the class

      // d.it('evaluates message sending', function(a) {
      //   pushCode("'abc'.class; nil.class");
      //   assertNextExpressions(a, [
      //     world.stringLiteral('abc'),
      //     world.stringClass,
      //     world.rubyNil,
      //     world.rubyNil.klass,
      //     world.rubyNil.klass,
      //   ]);
      // });

      // d.it('instantiates objects', function(a) {
      //   pushCode("class AC
      //             end
      //             BasicObject.new
      //             String.new
      //             AC.new
      //           ");
      //   interpreter.evaluateAll();
      //   var os  = world.objectSpace;
      //   // This is precarious: could fail if new creates additional objects :/
      //   var ac  = os[os.length - 1];
      //   var str = os[os.length - 2];
      //   var bo  = os[os.length - 3];

      //   a.eq(world.toplevelNamespace.constants['AC'], ac.klass);
      //   a.eq(world.stringClass,                       str.klass);
      //   a.eq(world.basicObjectClass,                  bo.klass);
      //   // Instantiation
      //   //   new
      //   //     returns a RObject with klass set to self
      //   //     initializes the object, passing the params
      //   //   allocate
      //   //     makes an RObject with the klass set
      //   //   // Object#initialize
      //   //   //   takes no params, does nothing
      // });


      // d.example('the acceptance test', function(a) {
      //   pushCode('
      //     class User
      //       def initialize(name)
      //         self.name = name
      //       end

      //       def name
      //         @name
      //       end

      //       def name=(name)
      //         @name = name
      //       end
      //     end

      //     user = User.new("Josh")
      //     puts user.name'
      //   );

      //   interpreter.evaluateAll();

      //   var userClassObj:Dynamic = world.toplevelNamespace.constants['User'];
      //   var userClass:RClass     = userClassObj;

      //   a.neq(null, userClass.imeths['initialize']);
      //   a.neq(null, userClass.imeths['name']);
      //   a.neq(null, userClass.imeths['name=']);

      //   // the code successfully printed
      //   a.streq(["Josh\n"], world.printedToStdout);

      //   // it is tracking the instance
      //   var users = world.eachObject(userClass);
      //   a.eq(1, users.length);
      //   var user = users[0];

      //   // the instance has the ivar set
      //   a.eq(world.stringClass, user.ivars['@name'].klass);
      //   var nameD:Dynamic = user.ivars['@name'];
      //   var name:RString  = nameD;
      //   a.eq("Josh", name.value);
      // });
    });
  }
}
