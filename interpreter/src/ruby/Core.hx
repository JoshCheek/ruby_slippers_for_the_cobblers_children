package ruby;
import ruby.ds.objects.*;

class Core {
  public static function lookupClass(bnd:RBinding, world:ruby.World):RObject {
    return bnd.self.klass;
  }

  public static function allocate(bnd:RBinding, world:ruby.World):RObject {
    var tmp:Dynamic  = bnd.self;
    var klass:RClass = tmp;
    var instance:RObject = {
      klass:klass,
      ivars:new ruby.ds.InternalMap(),
    }
    world.objectSpace.push(instance);
    return instance;
  }
}
