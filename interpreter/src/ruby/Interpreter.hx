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
  private var world:ruby.World;

  public function new(world:ruby.ds.World) {
    this.world = new ruby.World(world);
  }

  public function pushCode(code:Ast) {
  }

  public function nextExpression():RObject {
    return world.rubyNil;
  }

  public function step() {
  }

  public function isInProgress() {
    return world.stackSize == 0;
  }

  public function evaluateAll():RObject {
    return world.rubyNil;
  }

  // ----- PRIVATE -----

  // function get_isUnfinished() {
  //   switch(getEval()) {
  //     // the terminals
  //     case Finished|Evaluated(_)|EvaluationList(ListEnd):
  //       return false;
  //     case _:
  //       return true;
  //   }
  // }

  // // updates current evaluation, updates current expression if relevant;
  // private function setEval(evaluation:EvaluationState):EvaluationState {
  //   switch(evaluation) {
  //     case Evaluated(obj):
  //       world.currentExpression = obj;
  //       _evaluationFinished = true; // TODO: this name is terrible! there's a Finished value in EvaluationState, but we're actually talking about when an evaluation resolves to an object that a user could see
  //     case EvaluationList(Cons(crnt, _)):
  //       setEval(crnt); // child might have finished (FIXME: we're doing 2 responsibilities here, setting eval and setting currentExpression, which is why lines like this are necessary and confusing)
  //     case SetLocal(_, value):
  //       setEval(value);
  //     case _:
  //       _evaluationFinished = false;
  //   }
  //   currentEvaluation = evaluation;
  //   return evaluation;
  // }

  // private function getEval():EvaluationState {
  //   return currentEvaluation;
  // }

  // private function evaluationFinished():Bool {
  //   return _evaluationFinished;
  // }

  // private function continueEvaluating(toEval:EvaluationState) {
  //   switch(toEval) {
  //     // case Send(Evaluated(target), message):              throw "need to actually do shit now";
  //     // case Send(target, message):                         return Send(continueEvaluating(target), message);
  //     case EvaluationList(Cons(Evaluated(obj), ListEnd)): return Evaluated(obj);
  //     case EvaluationList(Cons(Evaluated(obj), rest)):    return EvaluationList(rest);
  //     case EvaluationList(Cons(current, rest)):           return EvaluationList(Cons(continueEvaluating(current), rest));
  //     case GetLocal(name):                                return Evaluated(world.getLocal(name));
  //     case SetLocal(name, Evaluated(value)):              return Evaluated(world.setLocal(name, value));
  //     case SetLocal(name, value):                         return SetLocal(name, continueEvaluating(value));
  //     case Evaluated(_):                                  return Finished;
  //     case Unevaluated(ast):                              return astToEvaluation(ast);
  //     case ConstantName(Lookup(ImplicitNamespace, name)):
  //       // Where is it supposed to look these up? this is one thing I don't fully understand about Ruby :/
  //       return Evaluated(world.toplevelNamespace.constants[name]);

  //     case ConstantName(Lookup(namespace, name)): throw "multiple namespaces not yet handled!";
  //     case Finished:                              throw new NothingToEvaluateError("Check before evaluating!");

  //     // fucking ADTS are stupid, even splitting out those values into their own types doesn't prevent stupid shit like this
  //     case ConstantName(ImplicitNamespace): throw "This shouldn't be possible!";
  //     case EvaluationList(ListEnd):         throw "This shouldn't be possible!";
  //   }
  // }

  // private function astToEvaluation(ast:Ast):EvaluationState {
  //   switch(ast) {
  //     case AstSend(target, message, args): return Evaluated(world.stringLiteral("SEND NOT ACTUALL IMPLEMENTED")); // Send(astToEvaluation(target), message);
  //     case AstConstant(namespace, name):   // FIXME: not handling namespace properly
  //                                          return ConstantName(Lookup(ImplicitNamespace, name));
  //     case AstFalse:                       return Evaluated(world.rubyFalse);
  //     case AstTrue:                        return Evaluated(world.rubyTrue);
  //     case AstNil:                         return Evaluated(world.rubyNil);
  //     case AstString(value):               return Evaluated(world.stringLiteral(value));
  //     case AstExpressions(exprs):
  //       return
  //         if(exprs.length == 0)      Evaluated(world.rubyNil);
  //         else if(exprs.length == 1) EvaluationList(Cons(astToEvaluation(exprs[0]), ListEnd));
  //         else                       EvaluationList(exprs
  //                                      .fromEnd()
  //                                      .fold(
  //                                        function(el, lst) return Cons(astToEvaluation(el), lst),
  //                                        ListEnd
  //                                      ));
  //     case AstGetLocalVariable(name):        return GetLocal(name);
  //     case AstSetLocalVariable(name, value): return SetLocal(name, astToEvaluation(value));
  //     case _:
  //       throw "Unhandled: " + ast;
  //   }
  // }
}
