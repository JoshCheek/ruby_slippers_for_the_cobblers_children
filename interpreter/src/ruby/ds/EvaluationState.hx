package ruby.ds;
import ruby.ds.objects.RObject;

// currently these are stored on World
// not sure this is where they belong
enum EvaluationState {
  // generic
  Unevaluated(ast:Ast);
  Evaluated(object:RObject);
  Finished;

  // evaluation lists
  EvaluationList(current:EvaluationState, next:EvaluationState);
  EvaluationListEnd;
}
