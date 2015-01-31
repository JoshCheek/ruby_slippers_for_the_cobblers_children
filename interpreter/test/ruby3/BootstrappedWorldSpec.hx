package ruby3;

import ruby3.Objects;
using Lambda;
using Inspect;

class BootstrappedWorldSpec {
  static function assertInObjectSpace(a:spaceCadet.Asserter, obj:RObject, world:ruby3.World, ?pos:haxe.PosInfos):Void {
    var found = null;
    for(potential in world.objectSpace)
      if(potential == obj) {
        found = true;
        break;
      }
    a.eqm(true, found, '${obj.inspect()} is in ObjectSpace');
  }

  // IDK if this goes here, but should also check:
  // ObjectSpace tracks clases, symbols, instances, bindings
  public static function describe(d:spaceCadet.Description) {
    d.describe('A bootstrapped world', function(d) {
      var world : ruby3.World;

      d.before(function(a) {
        world = ruby3.Bootstrap.bootstrap();
      });

      d.context('Execution environment', function(d) {
        d.specify('toplevelNamespace is Object', function(a) {
          a.eq(world.rcObject, world.toplevelNamespace);
        });

        d.describe('toplevelBinding', function(d) {
          d.it('assertions', function(a) {
            var tlb = world.rToplevelBinding;
            a.eq(tlb.self, world.rMain);         // is the main object
            a.eq(tlb.defTarget, world.rcObject); // it defines methods on Object
            a.eq(true, tlb.lvars.empty());       // it initializes with no local vars
            assertInObjectSpace(a, tlb, world);  // it is tracked in ObjectSpace
          });
        });

        d.describe('rMain', function(a) {
          d.it('is an object, it is in object space', function(a) {
            a.eq(world.rcObject, world.rMain.klass);
            assertInObjectSpace(a, world.rMain, world);
          });
        });
      });

      d.context('Special objects', function(d) {
        d.example('nil, true, false', function(a) {
          a.eq('NilClass',   world.rNil.klass.name);
          a.eq('TrueClass',  world.rTrue.klass.name);
          a.eq('FalseClass', world.rFalse.klass.name);
          assertInObjectSpace(a, world.rNil, world);
          assertInObjectSpace(a, world.rTrue, world);
          assertInObjectSpace(a, world.rFalse, world);
        });
      });

      d.context('Object hierarchy', function(d) {
        function assertClassDef(a:spaceCadet.Asserter, self:RClass, name:String, superclass:RClass, world:ruby3.World) {
          a.eq(name,          self.name);
          a.eq(world.rcClass, self.klass);
          a.eq(superclass,    self.superclass);
          if(null == world.toplevelNamespace.constants[name])
            throw "Need to put the class in the toplevel namespace!";
          a.eq(cast(self, RObject), world.toplevelNamespace.constants[name]);
          assertInObjectSpace(a, self, world);
        }
        d.specify('lots of assertions, just stuck here for the transition to spaceCadet', function(a) {
          assertClassDef(a, world.rcClass,       "Class",       world.rcModule,      world);
          assertClassDef(a, world.rcModule,      "Module",      world.rcObject,       world);
          assertClassDef(a, world.rcObject,      "Object",      world.rcBasicObject, world);
          assertClassDef(a, world.rcBasicObject, "BasicObject", null,                world);
          assertClassDef(a, world.rNil.klass,    "NilClass",    world.rcObject,       world);
          assertClassDef(a, world.rTrue.klass,   "TrueClass",   world.rcObject,       world);
          assertClassDef(a, world.rFalse.klass,  "FalseClass",  world.rcObject,       world);

          assertClassDef(a, world.rcString, "String", world.rcObject, world);
          assertClassDef(a, world.rcSymbol, "Symbol", world.rcObject, world);
        });
      });
    });
  }
}
