package ruby.ds;
import ruby.ds.objects.RObject;

enum EvaluationState {
  PullFromWorkQueue;
  // NotYetHandled;
  Finished(object:RObject);
  // FinishedSubEvaluation(object:RObject, rest:EvaluationState);
  // ToEvaluate(ast:Ast);
  // ExpressionList(expressions:Array<Ast>);
}
