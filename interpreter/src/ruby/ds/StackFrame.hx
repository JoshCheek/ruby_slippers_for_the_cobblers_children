package ruby.ds;

import ruby.ds.objects.RBinding;

typedef StackFrame = {
  public var ast:Ast;
  public var binding:RBinding;
  public var state:Interpreter.ExecutionState;
}
