package ruby;

import ruby.ds.Ast;
import ruby.ds.InternalMap;
import ruby.ds.World;
import ruby.ds.objects.*;

using ruby.LanguageGoBag;
using ruby.WorldWorker;
using ruby.ds.EvaluationState;
using Lambda;

// can we shorten some of these fkn names?
// getting annoying to type/read -.-
class Interpreter {
  public var world:World;
  private var _evaluationFinished:Bool;

  // TODO: move currentEvaluation back to Interpreter?
  public function new(world:World) {
    this.world               = world;
    this._evaluationFinished = false;
  }

  public function addCode(code:Ast) {
    setEval(EvaluationList(
              Unevaluated(code),
              world.currentEvaluation
            ));
  }

  // FIXME: not correctly stopping
  public function nextExpression() {
    do nextEvaluation() while(!evaluationFinished());
    return world.currentExpression;
  }

  public function nextEvaluation() {
    var e = getEval();
    // trace("NEXT EVALUATION CALLED, evaluation: " + e);
    return setEval(continueEvaluating(getEval()));
  }

  // ----- PRIVATE -----

  private function setEval(evaluation:EvaluationState):EvaluationState {
    // trace("CALLED SETEVAL, WITH: " + evaluation);
    switch(evaluation) {
      case Evaluated(obj):
        world.currentExpression = obj;
        // trace("EVALUATION **IS** FINISHED");
        _evaluationFinished = true;
      case EvaluationList(subEvaluation, _):
        setEval(subEvaluation);
        // trace("EVALUATION **IS** FINISHED");
      case _:
        // trace("EVALUATION **ISNOT** FINISHED");
        _evaluationFinished = false;
    }
    world.currentEvaluation = evaluation;
    return evaluation;
  }

  private function getEval():EvaluationState {
    return world.currentEvaluation;
  }

  private function evaluationFinished():Bool {
    return _evaluationFinished;
  }

  private function continueEvaluating(toEval:EvaluationState) {
    switch(toEval) {
      case Unevaluated(ast):                                  return astToEvaluation(ast);
      case Evaluated(obj):                                    return Finished;
      case EvaluationList(Evaluated(obj), EvaluationListEnd): return Evaluated(obj);
      case EvaluationList(Evaluated(obj), rest):              return rest;
      case EvaluationList(current, rest):                     return EvaluationList(continueEvaluating(current), rest);
      case EvaluationListEnd:
        // should see we are about to end, and return prev expression
        // I think... or maybe it should return Evaluated(world.rubyNil), not sure. Can we find a test for it?
        throw "Reached EvaluationListEnd, which should not happen!";
      case Finished:
        throw "Tried to continue evaluating when there is nothing left to do!";
    }
  }

  private function astToEvaluation(ast:Ast):EvaluationState {
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
