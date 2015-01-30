package ruby2;
import ruby2.ast.*;
import ruby2.Objects;

class Interpreter {
  var world:ruby2.World;

  public function new(world) {
    this.world             = world;
    this.currentExpression = world.rNil;
  }

  public function pushAst(ast:Ast) {
    if(ast == null)
      throw new Errors.NothingToEvaluate("Nothing to push!");
  }

  public var currentExpression(default, null):RObject;

  // ----- private -----
}
