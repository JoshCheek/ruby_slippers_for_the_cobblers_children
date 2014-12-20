package ruby;
import ruby.ds.InternalMap;
import ruby.ds.objects.*;

class WorldDomination {
  public static function bootstrap():ruby.ds.World {
    // a whole new world
    var objectSpace = [];
    var symbols     = new InternalMap();

    // Object / Class / Module
    var basicObjectClass:RClass = {
      name:       "BasicObject",
      klass:      null,
      superclass: null,
      ivars:      new InternalMap(),
      imeths:     new InternalMap(),
      constants:  new InternalMap(),
    };

    var objectClass:RClass = {
      name:       "Object",
      klass:      null,
      superclass: basicObjectClass,
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

    var moduleClass:RClass = {
      name:       'Module',
      klass:      klassClass,
      superclass: objectClass,
      ivars:      new InternalMap(),
      imeths:     new InternalMap(),
      constants:  new InternalMap(),
    }

    basicObjectClass.klass = klassClass;
    objectClass.klass      = klassClass;
    klassClass.klass       = klassClass;
    klassClass.superclass  = moduleClass;

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
    var trueClass:RClass = {
      name:       "TrueClass",
      klass:      klassClass,
      superclass: objectClass,
      ivars:      new InternalMap(),
      imeths:     new InternalMap(),
      constants:  new InternalMap(),
    };
    var falseClass:RClass = {
      name:       "FalseClass",
      klass:      klassClass,
      superclass: objectClass,
      ivars:      new InternalMap(),
      imeths:     new InternalMap(),
      constants:  new InternalMap(),
    };
    var nilClass:RClass = {
      name:       "NilClass",
      klass:      klassClass,
      superclass: objectClass,
      ivars:      new InternalMap(),
      imeths:     new InternalMap(),
      constants:  new InternalMap(),
    };
    var rubyNil   = {klass: nilClass,   ivars: new InternalMap()};
    var rubyTrue  = {klass: trueClass,  ivars: new InternalMap()};
    var rubyFalse = {klass: falseClass, ivars: new InternalMap()};

    // namespacing
    var toplevelNamespace = objectClass;
    toplevelNamespace.constants.set(klassClass.name,       klassClass);
    toplevelNamespace.constants.set(moduleClass.name,      moduleClass);
    toplevelNamespace.constants.set(objectClass.name,      objectClass);
    toplevelNamespace.constants.set(basicObjectClass.name, basicObjectClass);
    toplevelNamespace.constants.set(nilClass.name,         nilClass);
    toplevelNamespace.constants.set(falseClass.name,       falseClass);
    toplevelNamespace.constants.set(trueClass.name,        trueClass);


    return {
      stack             : [toplevelBinding],
      objectSpace       : objectSpace,
      symbols           : symbols,
      toplevelNamespace : objectClass,
      currentExpression : rubyNil,

      main              : main,
      rubyNil           : rubyNil,
      rubyTrue          : rubyTrue,
      rubyFalse         : rubyFalse,
      klassClass        : klassClass,
      moduleClass       : moduleClass,
      objectClass       : toplevelNamespace,
      basicObjectClass  : basicObjectClass,
      toplevelBinding   : toplevelBinding,
    }

  }
}
