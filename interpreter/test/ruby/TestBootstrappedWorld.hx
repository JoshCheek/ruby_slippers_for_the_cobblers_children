package ruby;

class TestBootstrappedWorld extends ruby.support.TestCase {
  /*****  EXECUTION ENVIRONMENT  *****/
  function testStackStartsAtTOPLEVEL_BINDING() {
    assertEquals(1, world.stack.length);
    rAssertEq(world.toplevelBinding, world.stack[0]);
  }

  // TOPLEVEL_BINDING's self is main
  // TOPLEVEL_BINDING's deftarget is Object
  // TOPLEVEL_BINDING starts with no locals
  // main is an instance of Object

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
