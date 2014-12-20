package ruby;

import ruby.ds.objects.RClass;
using Lambda;

// FIXME: we are using the ruby.ds.World, not ruby.World :/
class TestBootstrappedWorld extends ruby.support.TestCase {
  /*****  EXECUTION ENVIRONMENT  *****/
  function testStackOnlyContsinasTOPLEVEL_BINDING() {
    assertEquals(1, world.stack.length);
    assertEquals(world.toplevelBinding, world.stack[0]);
  }

  function testTOPLEVEL_BINDING() {
    var tlb = world.toplevelBinding;
    rAssertEq(tlb.self, world.main);
    rAssertEq(tlb.defTarget, world.objectClass);
    assertTrue(tlb.lvars.empty());
  }

  function testMain() {
    rAssertEq(world.objectClass, world.main.klass);
  }

  /*****  SPECIAL OBJECTS  *****/
  function testSpecialObjects() {
    assertEquals('NilClass',   world.rubyNil.klass.name);
    assertEquals('TrueClass',  world.rubyTrue.klass.name);
    assertEquals('FalseClass', world.rubyFalse.klass.name);
  }


  /*****  OBJECT HIERARCHY  *****/
  // TODO: Also check they're all namespaced under the toplevel constant (Object)
  function assertClassDef(self:RClass, name:String, superclass:RClass) {
    assertEquals(name,             self.name);
    assertEquals(world.klassClass, self.klass);
    assertEquals(superclass,       self.superclass);
  }

  function testClass()       assertClassDef(world.klassClass,       "Class",       world.moduleClass);
  function testModule()      assertClassDef(world.moduleClass,      "Module",      world.objectClass);
  function testObject()      assertClassDef(world.objectClass,      "Object",      world.basicObjectClass);
  function testBasicObject() assertClassDef(world.basicObjectClass, "BasicObject", null);
  function testNilClass()    assertClassDef(world.rubyNil.klass,    "NilClass",    world.objectClass);
  function testTrueClass()   assertClassDef(world.rubyTrue.klass,   "TrueClass",   world.objectClass);
  function testFalseClass()  assertClassDef(world.rubyFalse.klass,  "FalseClass",  world.objectClass);

  /*****  Objects Are Tracked  *****/
  // main
  // TOPLEVEL_BINDING
  // Class
  // Object
}

/*
 ObjectSpace tracks
   clases, symbols, instances, bindings

 */
