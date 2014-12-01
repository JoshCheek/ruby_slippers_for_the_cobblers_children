package ruby;
import ruby.ds.InternalMap;
import ruby.ds.objects.*;

class WorldDomination {
  public static function bootstrap():ruby.ds.World {
    // a whole new world
    var workToDo                = new List();
    var objectSpace             = [];
    var symbols                 = new InternalMap();

    // Object / Class
    var objectClass               = new RClass();
    objectClass.name              = "Object";
    objectClass.instanceVariables = new InternalMap();
    objectClass.instanceMethods   = new InternalMap();
    objectClass.constants         = new InternalMap();

    var klassClass                = new RClass();
    klassClass.name               = "Class";
    klassClass.instanceVariables  = new InternalMap();
    klassClass.instanceMethods    = new InternalMap();
    klassClass.superclass         = objectClass;

    klassClass.klass              = klassClass;
    objectClass.klass             = klassClass;

    // main
    var main               = new RObject();
    main.klass             = objectClass;
    main.instanceVariables = new InternalMap();

    // setup stack
    var toplevelBinding               = new RBinding();
    toplevelBinding.klass             = objectClass;
    toplevelBinding.instanceVariables = new InternalMap();
    toplevelBinding.self              = main;
    toplevelBinding.defTarget         = objectClass;
    toplevelBinding.lvars             = new InternalMap();

    // special constants
    var rubyNil                 = new RObject();
    rubyNil.klass               = objectClass; // should be NilClass
    rubyNil.instanceVariables   = new InternalMap();

    var rubyTrue                = new RObject();
    rubyTrue.klass              = objectClass; // should be TrueClass
    rubyTrue.instanceVariables  = new InternalMap();

    var rubyFalse               = new RObject();
    rubyFalse.klass             = objectClass; // should be FalseClass
    rubyFalse.instanceVariables = new InternalMap();

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
