package ruby.ds;
import ruby.ds.objects.RObject;
import ruby.ds.objects.RClass;
import ruby.ds.objects.RBinding;

typedef StackFrame = {
  public var ast:Ast;
  public var binding:RBinding;
  public var state:ExecutionState;
}

// TODO: remove world, and have Interpreter be an attribute of World
// ie "namespacing" chunks of related data
typedef Interpreter = {
  public var world:ruby.ds.World;
  public var stack:List<StackFrame>;
}

enum SetLocalState {
  FindRhs(name:String, rhs:Ast);
  SetLhs(name:String);
}
enum GetConstState {
  ResolveNs(namespace:Ast, name:String);
  Get(name:String);
}

enum ExecutionState {
  Self;
  GetLocal(name:String);
  SetLocal(state:SetLocalState);
  Value(obj:RObject);
  PendingValue(fn:Void->RObject);
  GetConst(state:GetConstState);

  Expressions(s:{crnt:Int, expressions:Array<Ast>});
  OpenClass(s:{state:String, name:String, nsCode:Ast, ns:RClass, klass:RClass});
  Send(s:{state:String, targetCode:Ast, target:RObject, message:String, argsCode:Array<Ast>, args:Array<RObject>});
}

enum EvaluationResult {
  Push(newState:ExecutionState, code:Ast, binding:ruby.ds.objects.RBinding);
  Pop(returnValue:RObject);
  NoAction(newState:ExecutionState);
}

