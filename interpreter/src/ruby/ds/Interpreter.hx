package ruby.ds;
import ruby.ds.objects.RObject;
import ruby.ds.objects.RClass;

// TODO: move StackFrame to this file
// TODO: move stack and currentExpression onto Interpreter
typedef Interpreter = {
  public var world:ruby.ds.World;
  public var stack:List<StackFrame>;
}

enum SetLocalState {
  FindRhs(name:String, rhs:Ast);
  SetLhs(name:String);
}

enum ExecutionState {
  Self;
  Value(obj:RObject);
  PendingValue(fn:Void->RObject);
  Expressions(s:{crnt:Int, expressions:Array<Ast>});
  SetLocal(state:SetLocalState);
  GetLocal(s:{name:String});
  GetConst(s:{state:String, name:String, nsCode:Ast});
  OpenClass(s:{state:String, name:String, nsCode:Ast, ns:RClass, klass:RClass});
  Send(s:{state:String, targetCode:Ast, target:RObject, message:String, argsCode:Array<Ast>, args:Array<RObject>});
}
