package ruby2;

import ruby2.ds.Objects;
using Lambda;
using Inspect;

class BootstrappedWorldSpec {
  static function assertInObjectSpace(a:spaceCadet.Asserter, obj:RObject, world:ruby2.World, ?pos:haxe.PosInfos):Void {
    var found = null;
    for(potential in world.objectSpace)
      if(potential == obj) {
        found = true;
        break;
      }
    a.eqm(true, found, '${obj.inspect()} is in ObjectSpace');
  }

  public static function describe(d:spaceCadet.Description) {
    var worldDs     : ruby2.ds.World;
    var world       : ruby2.World;
    var interpreter : ruby2.Interpreter;

    d.before(function(a) {
      worldDs     = ruby2.Bootstrap.bootstrap();
      world       = new ruby2.World(worldDs);
      interpreter = world.interpreter;
    });

    d.context('EXECUTION ENVIRONMENT', function(d) {
      d.specify('toplevelNamespace is Object', function(a) {
        a.eq(world.objectClass, world.toplevelNamespace);
      });

      d.describe('toplevelBinding', function(d) {
        d.it('assertions', function(a) {
          var tlb = world.toplevelBinding;
          a.eq(tlb.self, world.main); // is the main object
          a.eq(tlb.defTarget, world.objectClass); // it defines methods on Object
          a.eq(true, tlb.lvars.empty()); // it initializes with no local vars
          assertInObjectSpace(a, tlb, world); // it is tracked in ObjectSpace
        });
      });

      d.describe('main', function(a) {
        d.it('is an object, it is in object space', function(a) {
          a.eq(world.objectClass, world.main.klass);
          assertInObjectSpace(a, world.main, world);
        });
      });
    });

    d.context('SPECIAL OBJECTS', function(d) {
      d.example('nil, true, false', function(a) {
        a.eq('NilClass',   world.rubyNil.klass.name);
        a.eq('TrueClass',  world.rubyTrue.klass.name);
        a.eq('FalseClass', world.rubyFalse.klass.name);
        assertInObjectSpace(a, world.rubyNil, world);
        assertInObjectSpace(a, world.rubyTrue, world);
        assertInObjectSpace(a, world.rubyFalse, world);
      });
    });

    d.context('OBJECT HIERARCHY', function(d) {
      function assertClassDef(a:spaceCadet.Asserter, self:RClass, name:String, superclass:RClass, world:ruby2.World) {
        a.eq(name,             self.name);
        a.eq(world.classClass, self.klass);
        a.eq(superclass,       self.superclass);
        if(null == world.toplevelNamespace.constants[name])
          throw "Need to put the class in the toplevel namespace!";
        a.eq(cast(self, RObject), world.toplevelNamespace.constants[name]);
        assertInObjectSpace(a, self, world);
      }
      d.specify('lots of assertions, just stuck here for the transition to spaceCadet', function(a) {
        assertClassDef(a, world.classClass,       "Class",       world.moduleClass, world);
        assertClassDef(a, world.moduleClass,      "Module",      world.objectClass, world);
        assertClassDef(a, world.objectClass,      "Object",      world.basicObjectClass, world);
        assertClassDef(a, world.basicObjectClass, "BasicObject", null, world);
        assertClassDef(a, world.rubyNil.klass,    "NilClass",    world.objectClass, world);
        assertClassDef(a, world.rubyTrue.klass,   "TrueClass",   world.objectClass, world);
        assertClassDef(a, world.rubyFalse.klass,  "FalseClass",  world.objectClass, world);

        assertClassDef(a, world.stringClass, "String", world.objectClass, world);
        assertClassDef(a, world.symbolClass, "Symbol", world.objectClass, world);
      });
    });
    /*
     ObjectSpace tracks
       clases, symbols, instances, bindings
     */
  }
}
