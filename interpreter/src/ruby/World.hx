package ruby;

import ruby.ds.InternalMap;
import ruby.ds.objects.*;


// For now, this will become a god class,
// as it evolves, pay attention to its responsibilities so we can extract them into their own objects.
class World {
  private var world:ruby.ds.World;

  public function new(world:ruby.ds.World) {
    this.world = world;
  }

  public inline function toplevelNamespace():RClass {
    return world.toplevelNamespace;
  }

  public inline function getCurrentExpression():RObject {
    return world.currentExpression;
  }

  public inline function setCurrentExpression(value:RObject) {
    world.currentExpression = value;
  }

  public function intern(name:String):RSymbol {
    if(!world.symbols.exists(name)) {
      var symbol:RSymbol = {name: name, klass: world.objectClass, ivars: new InternalMap()};
      world.symbols.set(name, symbol);
    }
    return world.symbols.get(name);
  }

  public inline function currentBinding():RBinding {
    return world.stack[0]; // FIXME
  }



  // these don't even use the world
  public inline function hasMethod(methodBag:RClass, name:String):Bool {
    return methodBag.imeths.exists(name);
  }

  public inline function localsForArgs(meth:RMethod, args:Array<RObject>):InternalMap<RObject> {
    return new InternalMap(); // FIXME
  }

  public inline function getConstant(namespace:RClass, name:String):RObject {
    return namespace.constants.get(name);
  }

  public inline function setConstant(namespace:RClass, name:String, object:RObject):RObject {
    namespace.constants.set(name, object);
    return object;
  }

  public inline function getMethod(methodBag:RClass, methodName:String):RMethod {
    return methodBag.imeths.get(methodName);
  }

  // Objects special enough to have getter methods
  public var     rubyNil(get, never):RObject;
  public var   rubyFalse(get, never):RObject;
  public var    rubyTrue(get, never):RObject;
  public var objectClass(get, never):RClass;
  function     get_rubyNil() return world.rubyNil;
  function   get_rubyFalse() return world.rubyFalse;
  function    get_rubyTrue() return world.rubyTrue;
  function get_objectClass() return world.objectClass;
}
