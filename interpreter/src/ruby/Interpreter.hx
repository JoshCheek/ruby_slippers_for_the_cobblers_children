package ruby;

import ruby.ds.Ast;
import ruby.ds.InternalMap;
import ruby.ds.Errors;
import ruby.ds.objects.*;

using ruby.LanguageGoBag;
using ruby.ds.EvaluationState;
using Lambda;

// can we shorten some of these fkn names?
// getting annoying to type/read -.-
class Interpreter {
  var world               : ruby.World;
  var _evaluationFinished : Bool;
  var currentEvaluation   : EvaluationState;

  // TODO: move currentEvaluation back to Interpreter?
  public function new(world:ruby.ds.World) {
    this.world               = new ruby.World(world); // not sure if I actually like this or not
    this._evaluationFinished = false;
    this.currentEvaluation   = Finished;
  }

  // sets code to be evaluated
  public function addCode(code:Ast) {
    var list = EvaluationList(Unevaluated(code), currentEvaluation);
    setEval(list);
  }

  // evaluates until it finds an expression
  public function nextExpression() {
    do nextEvaluation() while(!evaluationFinished());
    return world.getCurrentExpression();
  }

  // iterate evaluation
  public function nextEvaluation() {
    var e = getEval();
    return setEval(continueEvaluating(getEval()));
  }

  // ----- PRIVATE -----

  // updates current evaluation, updates current expression if relevant;
  private function setEval(evaluation:EvaluationState):EvaluationState {
    switch(evaluation) {
      case Evaluated(obj):
        world.setCurrentExpression(obj);
        _evaluationFinished = true;
      case EvaluationList(subEvaluation, _):
        setEval(subEvaluation);
      case _:
        _evaluationFinished = false;
    }
    currentEvaluation = evaluation;
    return evaluation;
  }

  private function getEval():EvaluationState {
    return currentEvaluation;
  }

  private function evaluationFinished():Bool {
    return _evaluationFinished;
  }

  private function continueEvaluating(toEval:EvaluationState) {
    switch(toEval) {
      case Unevaluated(ast):                                  return astToEvaluation(ast);
      case EvaluationList(Evaluated(obj), EvaluationListEnd): return Evaluated(obj);
      case EvaluationList(Evaluated(obj), rest):              return rest;
      case EvaluationList(current, rest):                     return EvaluationList(continueEvaluating(current), rest);
      case EvaluationListEnd:
        // should see we are about to end, and return prev expression
        // I think... or maybe it should return Evaluated(world.rubyNil), not sure. Can we find a test for it?
        throw "Reached EvaluationListEnd, which should not happen!";
      case Evaluated(_) | Finished:
        throw new NothingToEvaluateError("Check before evaluating!");
    }
  }

  private function astToEvaluation(ast:Ast):EvaluationState {
    switch(ast) {
      case AstFalse:              return Evaluated(world.rubyFalse);
      case AstTrue:               return Evaluated(world.rubyTrue);
      case AstNil:                return Evaluated(world.rubyNil);
      case AstString(value):      return Evaluated(toRubyString(value));
      case AstExpressions(exprs):
        return
          if(exprs.length == 0)      Evaluated(world.rubyNil);
          else if(exprs.length == 1) EvaluationList(astToEvaluation(exprs[0]), EvaluationListEnd);
          else                       exprs
                                       .fromEnd()
                                       .fold(
                                         function(el, lst) return EvaluationList(astToEvaluation(el), lst),
                                         EvaluationListEnd
                                       );
      case _:
        throw "Unhandled: " + ast;
    }
  }


  private function toRubyString(value:String):RString {
    return { klass: world.objectClass,
      ivars: new InternalMap(),
      value: value,
    }
  }
}
