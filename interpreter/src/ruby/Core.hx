package ruby;
import ruby.ds.Objects;
import ruby.ds.InternalMap;
import ruby.ds.Interpreter;

class Core {
  public static function lookupClass(bnd:RBinding, world:ruby.World):EvaluationResult {
    return Pop(bnd.self.klass);
  }

  public static function initialize(bnd:RBinding, world:ruby.World):EvaluationResult {
    return Pop(world.rubyNil);
  }

  public static function puts(bnd:RBinding, world:ruby.World):EvaluationResult {
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
  public static function allocate(bnd:RBinding, world:ruby.World):EvaluationResult {
    var klassD:Dynamic = bnd.self;
    var restD:Dynamic  = bnd.lvars['rest'];

    var klass:RClass = klassD;
    var rest:RArray  = restD;

    var instance:RObject = {
      klass:klass,
      ivars:new ruby.ds.InternalMap(),
    }
    world.objectSpace.push(instance);

    // invoke initialize, return result
    return Push(
      Send(EndInternal(instance)),
      Send(Invoke(instance, "initialize", rest.elements)),
      { klass:     world.objectClass, // FIXME: should be Binding, not Object!
        ivars:     new InternalMap(),
        self:      instance,
        defTarget: klass, // TODO: UNTESTED
        lvars:     new InternalMap(),
      }
    );
  }
}
