package ruby2;
import ruby2.ast.*;

class Interpreter {
  var world:ruby2.World;

  public function new(world) {
    this.world = world;
  }

  public function pushAst(ast:Ast) {
    if(ast == null)
      throw new Errors.NothingToEvaluate("Nothing to push!");
  }
}
