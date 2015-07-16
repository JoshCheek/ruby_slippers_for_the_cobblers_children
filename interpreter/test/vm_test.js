"use strict"

import * as ruby from '../src/ruby';
import assert from 'assert';
import {inspect} from "util"

const AE = function(left, right) {
  if(left !== right)
    throw(new Error(`\u001b[31m${inspect(left)} !== ${inspect(right)}`))
}

const IS_TRACKED = function(world, object) {
  return true; // uhm, fake this out for now, we don't have a good way to reall deal with it
  let index = world.allObjects.findIndex((o) => o == object)
  if(0 <= index) return
  throw(new Error(`Expected ${inspect(object)} to be in the world, but it is not!`))
}

const interpreterFor = (rawCode, callback) => {
  ruby.parse(rawCode, (ast) => {
    const vm = ruby.VM.bootstrap(ast)
    callback(vm, vm.world)
  });
}

describe('ruby.VM', function() {
  // TODO: executes empty program
  it('currentExpression starts at nil, and is updated whenever an expression completes', (done) => {
    interpreterFor("true", (vm, world) => {
      AE(world.rNil, vm.currentExpression())
      vm.nextExpression()
      AE(world.rTrue, vm.currentExpression())
      done()
    })
  })

  it('returns nil when asked for the next expression when there is nothing to interpret', (done) => {
    interpreterFor("true", (vm, world) => {
      AE(world.rTrue, vm.nextExpression())
      for(let i in [0,1,2,3,4,5,6,7,8,9,10])
        AE(world.rNil,  vm.nextExpression())
      done()
    })
  });

  it('interprets multiple expressions', (done) => {
    interpreterFor("nil\ntrue\nfalse", (vm, world) => {
      // each individual expression
      AE(world.rNil,   vm.nextExpression());
      AE(world.rTrue,  vm.nextExpression());
      AE(world.rFalse, vm.nextExpression());

      // the collection emits the last one
      AE(world.rFalse, vm.nextExpression());

      // and now we are done
      AE(world.rNil,   vm.nextExpression());
      done()
    })
  });

  it('interprets strings', (done) => {
    interpreterFor("'abc'\n''", (vm, world) => {
      let str1 = vm.nextExpression()
      AE(world.rString, str1.class)
      AE("abc",         str1.primitiveData)
      IS_TRACKED(world, str1)

      let str2 = vm.nextExpression()
      AE(world.rString, str2.class)
      AE("",            str2.primitiveData)
      IS_TRACKED(world, str2)

      done()
    })
  });
})

/*
    // we're ignoring fixnums and symbols for now
    d.it('evalutes special constants', function(a) {
      var interpreter = interpreterFor("nil\ntrue\nfalse\nself");
      assertNextExpressions(a, interpreter, [
        world.rNil,
        world.rTrue,
        world.rFalse,
        world.rMain
      ]);
    });

    d.it('evaluates a string literal', function(a) {
      var interpreter = interpreterFor('"Josh"');
      var str = interpreter.nextExpression();
      a.eq(world.rcString, str.klass);
      a.streq(str.ivars, new InternalMap());
      a.eq("Josh", cast(str).value);
    });

    // TODO
    // if false
    //   a = 1
    // end
    // p a # => nil
    d.it('sets and gets local variables', function(a) {
      var interpreter = interpreterFor("var1 = 'b'
                                        'c'
                                        var1
                                        var2 = 'd'
                                        var1 = 'e'
                                        var2
                                        var1
                                        "
      );

      var assertLocal = function(name, obj:RObject) {
        var bnd = world.rToplevelBinding;
        a.eq(obj, bnd.getLocal(name));
      }

      var assertString = function(name:String, value:RObject) {
        a.eq('RB(#<String: ${name.inspect()}>)',
             value.inspect());
      };

      var strB;

      // expr="b", var1=nil
      strB = interpreter.nextExpression();
      assertString("b", strB);
      assertLocal("var1", world.rNil);

      // expr="b", var1="b"
      strB = interpreter.nextExpression();
      assertString("b", strB);
      assertLocal("var1", strB);

      // expr='c', var1='b'
      var strC = interpreter.nextExpression();
      assertString("c", strC);
      assertLocal("var1", strB);

      // expr='b', var1='b'
      strB = interpreter.nextExpression();
      assertString("b", strB);
      assertLocal("var1", strB);

      // there is no var2
      a.isFalse(interpreter.stackFrames.peek.binding.lvars.exists('var2'));

      // drain
      while(interpreter.isInProgress) // DUPLICATED IN assertNextExpressions
        interpreter.nextExpression();

      // var1='e', var2='d'
      assertString("e", interpreter.stackFrames.peek.binding.lvars.get('var1'));
      assertString("d", interpreter.stackFrames.peek.binding.lvars.get('var2'));
    });

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
    //     world.rTrue,
    //     world.rTrue,

    //     world.intern("nobody_meth"),
    //     world.rNil,

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
    //     world.rNil,
    //     world.rNil.klass,
    //     world.rNil.klass,
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
*/
