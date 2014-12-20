package ruby;

import ruby.ds.objects.RClass;
using Lambda;

// FIXME: we are using the ruby.ds.World, not ruby.World :/
class TestBootstrappedWorld extends ruby.support.TestCase {
  /*****  EXECUTION ENVIRONMENT  *****/
  function testToplevelNamespaceIsObject() {
    assertEquals(world.objectClass, world.toplevelNamespace);
  }

  function testStackOnlyContsinasTOPLEVEL_BINDING() {
    assertEquals(1, world.stackSize);
    assertEquals(world.toplevelBinding, world.currentBinding);
  }

  function testTOPLEVEL_BINDING() {
    var tlb = world.toplevelBinding;
    rAssertEq(tlb.self, world.main);
    rAssertEq(tlb.defTarget, world.objectClass);
    assertTrue(tlb.lvars.empty());
    assertInObjectSpace(tlb);
  }

  function testMain() {
    rAssertEq(world.objectClass, world.main.klass);
    assertInObjectSpace(world.main);
  }

  /*****  SPECIAL OBJECTS  *****/
  function testSpecialObjects() {
    assertEquals('NilClass',   world.rubyNil.klass.name);
    assertEquals('TrueClass',  world.rubyTrue.klass.name);
    assertEquals('FalseClass', world.rubyFalse.klass.name);
    assertInObjectSpace(world.rubyNil);
    assertInObjectSpace(world.rubyTrue);
    assertInObjectSpace(world.rubyFalse);
  }


  /*****  OBJECT HIERARCHY  *****/
  function assertClassDef(self:RClass, name:String, superclass:RClass) {
    assertEquals(name,             self.name);
    assertEquals(world.classClass, self.klass);
    assertEquals(superclass,       self.superclass);
    rAssertEq(self, world.toplevelNamespace.constants[name]);
    assertInObjectSpace(self);
  }

  function testClass()       assertClassDef(world.classClass,       "Class",       world.moduleClass);
  function testModule()      assertClassDef(world.moduleClass,      "Module",      world.objectClass);
  function testObject()      assertClassDef(world.objectClass,      "Object",      world.basicObjectClass);
  function testBasicObject() assertClassDef(world.basicObjectClass, "BasicObject", null);
  function testNilClass()    assertClassDef(world.rubyNil.klass,    "NilClass",    world.objectClass);
  function testTrueClass()   assertClassDef(world.rubyTrue.klass,   "TrueClass",   world.objectClass);
  function testFalseClass()  assertClassDef(world.rubyFalse.klass,  "FalseClass",  world.objectClass);

  function testStringClass() assertClassDef(world.stringClass, "String", world.objectClass);
}

/*
 ObjectSpace tracks
   clases, symbols, instances, bindings
 */
