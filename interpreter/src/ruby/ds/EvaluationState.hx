package ruby.ds;
import ruby.ds.objects.RObject;

enum EvaluationState {
  // generic
  Unevaluated(ast:Ast);
  Evaluated(object:RObject);
  Finished;

  // evaluation lists
  EvaluationList(current:EvaluationState, next:EvaluationState);
  EvaluationListEnd;
}
