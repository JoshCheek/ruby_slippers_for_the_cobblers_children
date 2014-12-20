package ruby;

using Lambda;

class TestBootstrappedWorld extends ruby.support.TestCase {
  /*****  EXECUTION ENVIRONMENT  *****/
  function testStackOnlyContsinasTOPLEVEL_BINDING() {
    assertEquals(1, world.stack.length);
    rAssertEq(world.toplevelBinding, world.stack[0]); // FIXME: passes trivially, b/c it's based on the shitty inspection in TestCase, which renders binding as #<Object>
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
  // nil's class is NilClass
  // true's class is TrueClass
  // false's class is FalseClass


  /*****  OBJECT HIERARCHY  *****/
  // TODO: Also check name in these
  // TODO: Also check they're all namespaced under the toplevel constant (Object)
  // Class's class is itself, its superclass is Module
  // Module's class is Class, its superclass is Object
  // Object's class is Class, its superclass is BasicObject
  // BasicObject's class is Class, its superclass is nil
  // NilClass's class is Class, its superclass is Object
  // TrueClass's class is Class, its superclass is Object
  // FalseClass's class is Class, its superclass is Object

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
