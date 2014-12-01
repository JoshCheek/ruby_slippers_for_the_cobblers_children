package ruby.ds;
import ruby.ds.objects.*;

// The container of all state
// though, might make sense to split it out from the work to do, idk
class World {
  public var stack              : Array<RBinding>;
  public var objectSpace        : Array<RObject>;
  public var currentExpression  : RObject;
  public var workToDo           : List<Void -> RObject>;
  public var toplevelNamespace  : RClass;
  public var symbols            : InternalMap<RSymbol>;
  public var rubyNil            : RObject;
  public var rubyTrue           : RObject;
  public var rubyFalse          : RObject;

  public var klassClass  : RClass;
  public var objectClass : RClass;

  public function new() null;

  public static function bootstrap():World {
    var world                     = new World();
    world.workToDo                = new List();
    world.objectSpace             = [];
    world.symbols                 = new InternalMap();

    // Object / Class
    world.objectClass                   = new RClass();
    world.objectClass.name              = "Object";
    world.objectClass.instanceVariables = new InternalMap();
    world.objectClass.instanceMethods   = new InternalMap();
    world.objectClass.constants         = new InternalMap();

    world.klassClass                    = new RClass();
    world.klassClass.name               = "Class";
    world.klassClass.instanceVariables  = new InternalMap();
    world.klassClass.instanceMethods    = new InternalMap();
    world.klassClass.superclass         = world.objectClass;

    world.klassClass.klass              = world.klassClass;
    world.objectClass.klass             = world.klassClass;
    world.toplevelNamespace             = world.objectClass;

    // main
    var main               = new RObject();
    main.klass             = world.objectClass;
    main.instanceVariables = new InternalMap();

    // setup stack
    var toplevelBinding               = new RBinding();
    toplevelBinding.klass             = world.objectClass;
    toplevelBinding.instanceVariables = new InternalMap();
    toplevelBinding.self              = main;
    toplevelBinding.defTarget         = world.toplevelNamespace;
    toplevelBinding.localVars         = new InternalMap();

    world.stack                       = [toplevelBinding];

    // special constants
    world.rubyNil                     = new RObject();
    world.rubyNil.klass               = world.objectClass; // should be NilClass
    world.rubyNil.instanceVariables   = new InternalMap();

    world.rubyTrue                    = new RObject();
    world.rubyTrue.klass              = world.objectClass; // should be TrueClass
    world.rubyTrue.instanceVariables  = new InternalMap();

    world.rubyFalse                   = new RObject();
    world.rubyFalse.klass             = world.objectClass; // should be FalseClass
    world.rubyFalse.instanceVariables = new InternalMap();

    world.currentExpression           = world.rubyNil;

    return world;
  }
}
