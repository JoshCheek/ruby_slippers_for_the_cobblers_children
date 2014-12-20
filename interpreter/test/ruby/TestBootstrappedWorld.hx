package ruby;

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
  function testClass() {
    var klass = world.klassClass;
    assertEquals("Class",           klass.name);
    assertEquals(world.klassClass,  klass.klass);
    assertEquals(world.moduleClass, klass.superclass);
  }

  function testModule() {
    var module = world.moduleClass;
    assertEquals("Module",          module.name);
    assertEquals(world.klassClass,  module.klass);
    assertEquals(world.objectClass, module.superclass);
  }

  function testObject() {
    var object = world.objectClass;
    assertEquals("Object",               object.name);
    assertEquals(world.klassClass,       object.klass);
    assertEquals(world.basicObjectClass, object.superclass);
  }

  function testBasicObject() {
    var basicObject = world.basicObjectClass;
    assertEquals("BasicObject",    basicObject.name);
    assertEquals(world.klassClass, basicObject.klass);
    assertEquals(null,             basicObject.superclass);
  }

  function testNilClass() {
    var nilClass = world.rubyNil.klass;
    assertEquals("NilClass",     nilClass.name);
    assertEquals(world.klassClass,  nilClass.klass);
    assertEquals(world.objectClass, nilClass.superclass);
  }

  function testTrueClass() {
    var trueClass = world.rubyTrue.klass;
    assertEquals("TrueClass",       trueClass.name);
    assertEquals(world.klassClass,  trueClass.klass);
    assertEquals(world.objectClass, trueClass.superclass);
  }

  function testFalseClass() {
    var falseClass = world.rubyFalse.klass;
    assertEquals("FalseClass",       falseClass.name);
    assertEquals(world.klassClass,  falseClass.klass);
    assertEquals(world.objectClass, falseClass.superclass);
  }

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
