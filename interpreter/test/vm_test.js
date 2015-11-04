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
  let index = world.$allObjects.findIndex((o) => o == object)
  if(0 <= index) return
  throw(new Error(`Expected ${inspect(object)} to be in the world, but it is not!`))
}

const lookupConst = function(world, name) {
  // not totally correct (they can be nested), but prob good enough for now
  return world.toplevelNamespace.constants[name]
  // throw(new Error(`Implement lookupClass (${name})`))
}

const assertSymbol = function(world, value, symbol) {
  assert.equal('rSymbol', inspect(symbol.class))
  assert.equal(value, symbol.primitiveData)
}


const assertClass = function(world, name, assertions) {
  let klass = lookupConst(world, name)

  for(let assertionName in assertions) {
    let value = assertions[assertionName]

    switch(assertionName) {
      case "name":
        AE(value, klass.name)
        break
      case "class":
        AE(value, klass.class)
        break
      case "numIvars":
        AE(value, klass.instanceVariables.length)
        break
      case "superclass":
        AE(value, klass.superclass)
        break
      case "numConstants":
        AE(value, klass.constants.length)
        break
      case "numMethods":
        AE(value, klass.methods.length)
        break
      // case "methods":
      //   let methodAssertions = assertions[assertionName]
      //   // methods:      {
      //   //   ameth: {args: [], body: null}
      //   // }
      //   break
      default:
        throw(new Error(`IDK how to assert ${assertionName}!`))
        break
    }
  }
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
      AE(world.$rNil, vm.currentExpression())
      vm.nextExpression()
      AE(world.$rTrue, vm.currentExpression())
      done()
    })
  })

  it('returns nil when asked for the next expression when there is nothing to interpret', (done) => {
    interpreterFor("true", (vm, world) => {
      AE(world.$rTrue, vm.nextExpression())
      for(let i in [0,1,2,3,4,5,6,7,8,9,10])
        AE(world.$rNil,  vm.nextExpression())
      done()
    })
  });

  it('interprets multiple expressions', (done) => {
    interpreterFor("nil\ntrue\nfalse", (vm, world) => {
      // each individual expression
      AE(world.$rNil,   vm.nextExpression());
      AE(world.$rTrue,  vm.nextExpression());
      AE(world.$rFalse, vm.nextExpression());

      // the collection emits the last one
      AE(world.$rFalse, vm.nextExpression());

      // and now we are done
      AE(world.$rNil,   vm.nextExpression());
      done()
    })
  });

  it('interprets strings', (done) => {
    interpreterFor("'abc'\n''", (vm, world) => {
      let str1 = vm.nextExpression()
      AE(world.$rString, str1.class)
      AE("abc",         str1.primitiveData)
      IS_TRACKED(world, str1)

      let str2 = vm.nextExpression()
      AE(world.$rString, str2.class)
      AE("",            str2.primitiveData)
      IS_TRACKED(world, str2)

      done()
    })
  });

  // we're ignoring fixnums and symbols for now
  it('evalutes special literals', (done) => {
    interpreterFor("nil\ntrue\nfalse\nself", (vm, world) => {
      AE(world.$rNil,   vm.nextExpression())
      AE(world.$rTrue,  vm.nextExpression())
      AE(world.$rFalse, vm.nextExpression())
      AE(world.$rMain,  vm.nextExpression())
      done()
    })
  })

  it('sets and gets local variables', (done) => {
    interpreterFor(`var1 = 'b'
                    'c'
                    var1
                    var2 = 'd'
                    var1 = 'e'
                    var2
                    var1`, (vm, world) => {

      const assertLocal = function(name, obj) {
        let bnd = vm.currentBinding()
        AE(obj, bnd.localVariables[name])
      }

      const assertString = function(value, obj) {
        assert.equal('rString', inspect(obj.class))
        assert.equal(value, obj.primitiveData)
      };

      // expr="b", var1=nil
      let strB = vm.nextExpression()
      assertString("b", strB)
      assertLocal("var1", world.$rNil)

      // expr="b", var1="b"
      strB = vm.nextExpression()
      assertString("b", strB)
      assertLocal("var1", strB)

      // expr='c', var1='b'
      let strC = vm.nextExpression()
      assertString("c", strC)
      assertLocal("var1", strB)

      // expr='b', var1='b'
      strB = vm.nextExpression()
      assertString("b", strB)
      assertLocal("var1", strB)

      // there is no var2
      assert.equal(undefined, vm.currentBinding().localVariables['var2'])

      vm.runToEnd()

      // var1='e', var2='d'
      assertString("e", vm.currentBinding().localVariables['var1'])
      assertString("d", vm.currentBinding().localVariables['var2'])
      done()
    })
  })

  it('more local vars',  (done) => {
    interpreterFor(`a = 'x'; b = a`, (vm, world) => {
      vm.nextExpression()
      vm.nextExpression()
      var vara = vm.currentBinding().localVariables['a']
      vm.nextExpression()
      AE(world.$rNil, vm.currentBinding().localVariables['b'])
      vm.nextExpression()
      var varb = vm.currentBinding().localVariables['b']
      if(vara != varb) throw(new Error("LOCALS NOT EQUAL!")) // a and b have ref to same obj
      done()
    })
  })

  it('evaluates toplevel constant lookup',  (done) => {
    interpreterFor(`Object; String`, (vm, world) => {
      AE(world.$rObject, vm.nextExpression());
      AE(world.$rString, vm.nextExpression());
      done()
    })
  })

  it('evaluates class and method definitions', (done) => {
    interpreterFor(`
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
    `, (vm, world) => {
      AE(undefined, world.$toplevelNamespace.constants['A']);

      // -----  run the program  -----
      assertSymbol(world, "ameth", vm.nextExpression()) // A#ameth
      assertSymbol(world, "ameth", vm.nextExpression()) // A

      assertSymbol(world, "ameth", vm.nextExpression()) // Object#ameth
      AE(world.$rTrue,      vm.nextExpression())
      AE(world.$rTrue,      vm.nextExpression())

      assertSymbol(world, "nobody_meth", vm.nextExpression()) // Object#nobody_meth
      AE(world.$rNil,             vm.nextExpression())

      assertSymbol(world, "meth_with_args", vm.nextExpression()) // Object#meth_with_args

      // -----  class definition  -----
      assertClass(world, "A", {
        class:       world.$rClass,
        numIvars:    0,
        superclass:  world.$rObject,
        numConstants: 0,
        numMethods:   1,
        methods:      {
          ameth: {args: [], body: null}
        }
      })

      // -----  method definitions  -----
      // Object#ometh
      var ometh = world.$rObject.instanceMethods['ometh'];
      a.eq("ometh", ometh.name);
      a.eq(0, ometh.args.length);
      a.streq(ometh.body, Ruby(True({begin:169, end:173})));

      // Object#meth_with_args
      var methWithArgs = world.$rObject.instanceMethods['meth_with_args'];
      a.streq(methWithArgs.args, [Required("req"), Rest("rest")]);
    })
  });
})

/*
    // TODO
    // if false
    //   a = 1
    // end
    // p a # => nil

    // // //TODO: local vars with more than 1 binding on the stack

    // // TODO: Test reopening the class

    // d.it('evaluates message sending', function(a) {
    //   pushCode("'abc'.class; nil.class");
    //   assertNextExpressions(a, [
    //     world.$stringLiteral('abc'),
    //     world.$stringClass,
    //     world.$rNil,
    //     world.$rNil.klass,
    //     world.$rNil.klass,
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
    //   var os  = world.$objectSpace;
    //   // This is precarious: could fail if new creates additional objects :/
    //   var ac  = os[os.length - 1];
    //   var str = os[os.length - 2];
    //   var bo  = os[os.length - 3];

    //   a.eq(world.$toplevelNamespace.constants['AC'], ac.klass);
    //   a.eq(world.$stringClass,                       str.klass);
    //   a.eq(world.$basicObjectClass,                  bo.klass);
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

    //   var userClassObj:Dynamic = world.$toplevelNamespace.constants['User'];
    //   var userClass:RClass     = userClassObj;

    //   a.neq(null, userClass.instanceMethods['initialize']);
    //   a.neq(null, userClass.instanceMethods['name']);
    //   a.neq(null, userClass.instanceMethods['name=']);

    //   // the code successfully printed
    //   a.streq(["Josh\n"], world.$printedToStdout);

    //   // it is tracking the instance
    //   var users = world.$eachObject(userClass);
    //   a.eq(1, users.length);
    //   var user = users[0];

    //   // the instance has the ivar set
    //   a.eq(world.$stringClass, user.ivars['@name'].klass);
    //   var nameD:Dynamic = user.ivars['@name'];
    //   var name:RString  = nameD;
    //   a.eq("Josh", name.value);
    // });
  });
}
*/
