package ruby;

class WorldSpec {
  static function assertInObjectSpace(a:spaceCadet.Asserter, obj:ruby.ds.Objects.RObject, world:ruby.World, ?pos:haxe.PosInfos):Void {
    var found = null;
    for(potential in world.objectSpace)
      if(potential == obj) {
        found = true;
        break;
      }
    a.eqm(true, found, '${obj.inspect()} is in ObjectSpace');
  }
  public static function describe(d:spaceCadet.Description) {
    d.example('string literals', function(a) {
      var world = new ruby.World(ruby.Bootstrap.bootstrap());
      var str   = world.stringLiteral("abc");
      a.eq("abc", str.value);              // have the correct value
      a.eq(world.stringClass, str.klass);  // are strings
      assertInObjectSpace(a, str, world);  // are tracked
    });
  }

  // FIXME: IMPLEMENT THIS
  // function testStackAndBindings() {
  //   assertEquals(world.toplevelBinding, world.currentBinding);
  //   var newBnd = world.bindingFor(world.rubyNil);
  //   refuteEquals(newBnd, world.toplevelBinding);
  //   world.pushStack(newBnd);
  //   assertEquals(newBnd, world.currentBinding);
  //   world.popStack();
  //   assertEquals(world.toplevelBinding, world.currentBinding);
  // }
}
