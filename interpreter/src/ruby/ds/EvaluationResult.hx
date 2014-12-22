package ruby.ds;
import ruby.ds.objects.RBinding;
import ruby.ds.objects.RObject;

enum EvaluationResult {
  Push(code:Ast, binding:RBinding);
  Pop(returnValue:RObject);
  NoAction;
}
