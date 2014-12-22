package ruby.ds;

import ruby.ds.objects.RBinding;
import ruby.ds.objects.RObject;

typedef StackFrame = {
  public var ast:Ast;
  public var binding:RBinding;
  public function step():EvaluationResult;
  public function returned(obj:RObject):Void;
}
