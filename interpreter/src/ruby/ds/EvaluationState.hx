package ruby.ds;
import ruby.ds.objects.RObject;

// currently these are stored on World
// not sure this is where they belong
enum EvaluationState {
  // generic
  Unevaluated(ast:Ast);
  Evaluated(object:RObject);
  Finished;
  EvaluationList(value:EvaluationListValue);
  GetLocal(name:String);
  SetLocal(name:String, value:EvaluationState);
}

enum EvaluationListValue {
  Cons(current:EvaluationState, next:EvaluationListValue);
  ListEnd;
}
