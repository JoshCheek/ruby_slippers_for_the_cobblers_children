package ruby2;
import ruby2.ds.Objects;
import ruby2.ds.InternalMap;
import ruby2.ds.Interpreter;

class Core {
  public static function lookupClass(bnd:RBinding, world:ruby2.World):EvaluationResult {
    return Pop(bnd.self.klass);
  }

  public static function initialize(bnd:RBinding, world:ruby2.World):EvaluationResult {
    return Pop(world.rubyNil);
  }

  public static function puts(bnd:RBinding, world:ruby2.World):EvaluationResult {
    var restD:Dynamic = bnd.lvars['rest'];
    var rest:RArray   = restD;
    for(printed in rest.elements) {
      var strD:Dynamic = printed;
      var str:RString  = strD;
      var toPrint = str.value + "\n";
      world.printedToStdout =
        world.printedToStdout.concat([toPrint]);
    }
    return Pop(world.rubyNil);
  }

  // currently this is doing the job of all of new!
  public static function allocate(bnd:RBinding, world:ruby2.World):EvaluationResult {
    var klassD:Dynamic = bnd.self;
    var restD:Dynamic  = bnd.lvars['rest'];

    var klass:RClass = klassD;
    var rest:RArray  = restD;

    var instance = new RObject();
    instance.klass = klass;
    instance.ivars = new ruby2.ds.InternalMap();

    world.objectSpace.push(instance);

    var bnd = new RBinding();
    bnd.klass     = world.objectClass; // FIXME: should be Binding, not Object!
    bnd.ivars     = new InternalMap();
    bnd.self      = instance;
    bnd.defTarget = klass; // TODO: UNTESTED
    bnd.lvars     = new InternalMap();


    // invoke initialize, return result
    return Push(
      Send(EndInternal(instance)),
      Send(Invoke(instance, "initialize", rest.elements)),
      bnd
    );
  }
}
