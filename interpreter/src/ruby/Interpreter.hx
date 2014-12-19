package ruby;

import ruby.ds.Ast;
import ruby.ds.InternalMap;
import ruby.ds.World;
import ruby.ds.objects.*;

using ruby.LanguageGoBag;
using ruby.WorldWorker;
using ruby.ds.EvaluationState;
using Lambda;

class Interpreter {
  public var world:World;

  public static function fromBootstrap():Interpreter {
    return new Interpreter(WorldDomination.bootstrap());
  }

  public function new(world:World) {
    this.world = world;
  }

  // not correctly stopping
  public function nextExpression() {
    do iterateEvaluation() while(!evaluationFinished());
    return world.currentExpression;
  }

  // fkn pattern matching -.- should be a 1-liner, not a 5-liner
  public function evaluationFinished():Bool {
    switch(world.currentEvaluation) {
      case Evaluated(obj):
        return true;
      case _:
        return false;
    }
  }

  public function iterateEvaluation():EvaluationState {
    var evaluation = continueEvaluating(world.currentEvaluation);
    world.currentEvaluation = evaluation;
    switch(evaluation) {
      case Evaluated(obj):
        world.currentExpression = obj;
      case _:
        // no op
    }
    return evaluation;
  }


  // receives an evaluationState, performs it on the world, returns the next one
  private function continueEvaluating(evaluationState:EvaluationState):EvaluationState {
    switch(evaluationState) {
      case Unevaluated(ast):
        return astToEvaluation(ast);

      // lists
      case EvaluationList(Evaluated(obj), EvaluationListEnd):
        return Evaluated(obj);
      case EvaluationList(Evaluated(_), rest):
        return rest;
      case EvaluationList(current, rest):
        return EvaluationList(continueEvaluating(current), rest);

      case Evaluated(obj):
        return Finished;

      case _:
        throw "Unhandled evaluation: " + world.currentEvaluation;
    }
  }

  public function astToEvaluation(ast:Ast):EvaluationState {
    switch(ast) {
      case AstFalse:
        return Evaluated(world.rubyFalse);
      case AstTrue:
        return Evaluated(world.rubyTrue);
      case AstNil:
        return Evaluated(world.rubyNil);
      case AstExpressions(expressions):
        if(expressions.length == 0) {
          return Evaluated(world.rubyNil);
        } else if(expressions.length == 1) {
          return EvaluationList(
             astToEvaluation(expressions[0]),
             EvaluationListEnd
           );
        } else {
           return expressions
                    .reverseIterator()
                    .fold(function(subAst, list) {
                            return EvaluationList(astToEvaluation(subAst), list);
                          }, EvaluationListEnd
                    );
        }
      case _:
        throw "Unhandled: " + ast;
    }
  }
}
