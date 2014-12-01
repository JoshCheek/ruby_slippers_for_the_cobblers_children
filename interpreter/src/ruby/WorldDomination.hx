package ruby;
import ruby.ds.InternalMap;
import ruby.ds.objects.*;

class WorldDomination {
  public static function bootstrap():ruby.ds.World {
    // a whole new world
    var workToDo    = new List();
    var objectSpace = [];
    var symbols     = new InternalMap();

    // Object / Class
    var objectClass:RClass = {
      name:       "Object",
      klass:      null,
      superclass: null,
      ivars:      new InternalMap(),
      imeths:     new InternalMap(),
      constants:  new InternalMap(),
    };

    var klassClass:RClass = {
      name:       "Class",
      klass:      null,
      superclass: objectClass,
      ivars:      new InternalMap(),
      imeths:     new InternalMap(),
      constants:  new InternalMap(),
    };

    klassClass.klass  = klassClass;
    objectClass.klass = klassClass;

    // main
    var main = {klass: objectClass, ivars: new InternalMap()};

    // setup stack
    var toplevelBinding = {
      klass:     objectClass,
      ivars:     new InternalMap(),
      self:      main,
      defTarget: objectClass,
      lvars:     new InternalMap(),
    };

    // special constants (classes are wrong)
    var rubyNil   = {klass: objectClass, ivars: new InternalMap()};
    var rubyTrue  = {klass: objectClass, ivars: new InternalMap()};
    var rubyFalse = {klass: objectClass, ivars: new InternalMap()};

    return {
      stack             : [toplevelBinding],
      workToDo          : workToDo,
      objectSpace       : objectSpace,
      symbols           : symbols,
      toplevelNamespace : objectClass,
      currentExpression : rubyNil,

      rubyNil           : rubyNil,
      rubyTrue          : rubyTrue,
      rubyFalse         : rubyFalse,
      klassClass        : klassClass,
      objectClass       : objectClass,
    }

  }
}
