package ruby;
import ruby.ds.InternalMap;
import ruby.ds.objects.*;

class Bootstrap {
  public static function bootstrap():ruby.ds.World {
    // a whole new world
    var objectSpace:Array<RObject> = [];
    var symbols = new InternalMap();

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

    // initial execution context
    var main = {klass: objectClass, ivars: new InternalMap()};

    var toplevelBinding:RBinding = {
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

    // core classes
    var stringClass:RClass = {
      name:       "String",
      klass:      klassClass,
      superclass: objectClass,
      ivars:      new InternalMap(),
      imeths:     new InternalMap(),
      constants:  new InternalMap(),
    };

    // namespacing
    var toplevelNamespace = objectClass;
    toplevelNamespace.constants[klassClass.name]       = klassClass;
    toplevelNamespace.constants[moduleClass.name]      = moduleClass;
    toplevelNamespace.constants[objectClass.name]      = objectClass;
    toplevelNamespace.constants[basicObjectClass.name] = basicObjectClass;
    toplevelNamespace.constants[nilClass.name]         = nilClass;
    toplevelNamespace.constants[trueClass.name]        = trueClass;
    toplevelNamespace.constants[falseClass.name]       = falseClass;
    toplevelNamespace.constants[stringClass.name]      = stringClass;

    // Object tracking
    objectSpace.push(toplevelBinding);
    objectSpace.push(main);
    objectSpace.push(rubyNil);
    objectSpace.push(rubyTrue);
    objectSpace.push(rubyFalse);

    objectSpace.push(klassClass);
    objectSpace.push(moduleClass);
    objectSpace.push(objectClass);
    objectSpace.push(basicObjectClass);
    objectSpace.push(nilClass);
    objectSpace.push(trueClass);
    objectSpace.push(falseClass);
    objectSpace.push(stringClass);

    // core methods

    // FIXME: Putting this here b/c it will get me further
    // but really it goes on Kernel, which doesn't exist yet,
    // b/c we have no modules yet
    objectClass.imeths["class"] = {
      klass: objectClass, // FIXME: SHOULD BE METHOD CLASS
      ivars: new InternalMap(),
      name: "class",
      args: [],
      body: ruby.ds.objects.RMethod.ExecutableType.Internal(Core.lookupClass),
    }

    // TODO: move this into Ruby, only allocate needs to be haxe level
    klassClass.imeths["new"] = {
      klass: objectClass, // FIXME: SHOULD BE METHOD CLASS
      ivars: new InternalMap(),
      name:  "new",
      args:  [],
      body:  ruby.ds.objects.RMethod.ExecutableType.Internal(Core.allocate),
    }

    // the data structure
    return {
      objectSpace       : objectSpace,
      symbols           : symbols,
      toplevelNamespace : toplevelNamespace,
      currentExpression : rubyNil,
      stack             : new List(),

      toplevelBinding   : toplevelBinding,
      main              : main,
      rubyNil           : rubyNil,
      rubyTrue          : rubyTrue,
      rubyFalse         : rubyFalse,

      basicObjectClass  : basicObjectClass,
      objectClass       : objectClass,
      moduleClass       : moduleClass,
      klassClass        : klassClass,
      stringClass       : stringClass,
    }

  }
}
