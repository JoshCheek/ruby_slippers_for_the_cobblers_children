package ruby;
import ruby.ds.InternalMap;
import ruby.ds.Objects;

class Bootstrap {
  public static function bootstrap():ruby.ds.World {
    // a whole new world
    var objectSpace:Array<RObject> = [];
    var symbols = new InternalMap();

    // Object / Class / Module
    var basicObjectClass = new RClass();
    basicObjectClass.name      = "BasicObject";
    basicObjectClass.ivars     = new InternalMap();
    basicObjectClass.imeths    = new InternalMap();
    basicObjectClass.constants = new InternalMap();

    var objectClass = new RClass();
    objectClass.name       = "Object";
    objectClass.klass      = null;
    objectClass.superclass = basicObjectClass;
    objectClass.ivars      = new InternalMap();
    objectClass.imeths     = new InternalMap();
    objectClass.constants  = new InternalMap();

    var klassClass = new RClass();
    klassClass.name       = "Class";
    klassClass.klass      = null;
    klassClass.superclass = objectClass;
    klassClass.ivars      = new InternalMap();
    klassClass.imeths     = new InternalMap();
    klassClass.constants  = new InternalMap();

    var moduleClass = new RClass();
    moduleClass.name       = 'Module';
    moduleClass.klass      = klassClass;
    moduleClass.superclass = objectClass;
    moduleClass.ivars      = new InternalMap();
    moduleClass.imeths     = new InternalMap();
    moduleClass.constants  = new InternalMap();

    basicObjectClass.klass = klassClass;
    objectClass.klass      = klassClass;
    klassClass.klass       = klassClass;
    klassClass.superclass  = moduleClass;

    // initial execution context
    var main = new RObject();
    main.klass = objectClass;
    main.ivars = new InternalMap();

    var toplevelBinding = new RBinding();
    toplevelBinding.klass     = objectClass;
    toplevelBinding.ivars     = new InternalMap();
    toplevelBinding.self      = main;
    toplevelBinding.defTarget = objectClass;
    toplevelBinding.lvars     = new InternalMap();

    // special constants (classes are wrong)
    var trueClass = new RClass();
    trueClass.name       = "TrueClass";
    trueClass.klass      = klassClass;
    trueClass.superclass = objectClass;
    trueClass.ivars      = new InternalMap();
    trueClass.imeths     = new InternalMap();
    trueClass.constants  = new InternalMap();

    var falseClass = new RClass();
    falseClass.name       = "FalseClass";
    falseClass.klass      = klassClass;
    falseClass.superclass = objectClass;
    falseClass.ivars      = new InternalMap();
    falseClass.imeths     = new InternalMap();
    falseClass.constants  = new InternalMap();

    var nilClass = new RClass();
    nilClass.name       = "NilClass";
    nilClass.klass      = klassClass;
    nilClass.superclass = objectClass;
    nilClass.ivars      = new InternalMap();
    nilClass.imeths     = new InternalMap();
    nilClass.constants  = new InternalMap();

    var rubyNil     = new RObject();
    rubyNil.klass   = nilClass;
    rubyNil.ivars   = new InternalMap();

    var rubyTrue    = new RObject();
    rubyTrue.klass  = trueClass;
    rubyTrue.ivars  = new InternalMap();

    var rubyFalse   = new RObject();
    rubyFalse.klass = falseClass;
    rubyFalse.ivars = new InternalMap();

    // core classes
    var stringClass = new RClass();
    stringClass.name       = "String";
    stringClass.klass      = klassClass;
    stringClass.superclass = objectClass;
    stringClass.ivars      = new InternalMap();
    stringClass.imeths     = new InternalMap();
    stringClass.constants  = new InternalMap();

    var symbolClass = new RClass();
    symbolClass.name       = "Symbol";
    symbolClass.klass      = klassClass;
    symbolClass.superclass = objectClass;
    symbolClass.ivars      = new InternalMap();
    symbolClass.imeths     = new InternalMap();
    symbolClass.constants  = new InternalMap();


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
    toplevelNamespace.constants[symbolClass.name]      = symbolClass;

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
    objectSpace.push(symbolClass);

    // core methods

    // FIXME: Putting this here b/c it will get me further
    // but really it goes on Kernel, which doesn't exist yet,
    // b/c we have no modules yet
    var meth:RMethod;
    objectClass.imeths["class"] = meth = new RMethod();
    meth.klass = objectClass; // FIXME: SHOULD BE METHOD CLASS
    meth.ivars = new InternalMap();
    meth.name  = "class";
    meth.args  = [];
    meth.body  = Internal(Core.lookupClass);

    // TODO: move this into Ruby, only allocate needs to be haxe level
    klassClass.imeths["new"] = meth = new RMethod();
    meth.klass = objectClass; // FIXME: SHOULD BE METHOD CLASS
    meth.ivars = new InternalMap();
    meth.name  = "new";
    meth.args  = [Rest("rest")];
    meth.body  = Internal(Core.allocate);

    objectClass.imeths['puts'] = meth = new RMethod();
    meth.klass = objectClass; // FIXME: SHOULD BE METHOD CLASS
    meth.ivars = new InternalMap();
    meth.name  = "puts";
    meth.args  = [Rest('rest')];
    meth.body  = Internal(Core.puts);

    basicObjectClass.imeths['initialize'] = meth = new RMethod();
    meth.klass = objectClass;  // FIXME: SHOULD BE METHOD CLASS
    meth.ivars = new InternalMap();
    meth.name  = "initialize";
    meth.args  = [];
    meth.body  = Internal(Core.initialize);

    // the data structure
    return {
      objectSpace       : objectSpace,
      symbols           : symbols,
      toplevelNamespace : toplevelNamespace,
      currentExpression : rubyNil,
      stack             : new List(),
      printedToStdout   : [],

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
      symbolClass       : symbolClass,
    }

  }
}
