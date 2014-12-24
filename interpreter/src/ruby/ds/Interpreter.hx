package ruby.ds;
import  ruby.ds.Objects;

// World is of this type
typedef Interpreter = {
  public var stack             : List<StackFrame>;
  public var currentExpression : RObject;
}

typedef StackFrame = {
  public var ast     : Ast;
  public var binding : RBinding;
  public var state   : ExecutionState;
}

enum EvaluationResult {
  NoAction (newState:ExecutionState);
  Push     (newState:ExecutionState, code:Ast, binding:RBinding);
  Pop      (returnValue:RObject);
}


enum ExecutionState {
  GetLocal  (state:GetLocalState);
  SetLocal  (state:SetLocalState);
  GetConst  (state:GetConstState);
  Exprs     (state:ExprsState);
  OpenClass (state:OpenClassState);
  Send      (state:SendState);
  Self      (state:SelfState);
  Value     (state:ValueState);
}
enum GetLocalState {
  Name(name:String);
}
enum SetLocalState {
  FindRhs(name:String, rhs:Ast);
  SetLhs(name:String);
}
enum GetConstState {
  ResolveNs(namespace:Ast, name:String);
  Get(name:String);
}
enum ExprsState {
  Crnt(index:Int, expressions:Array<Ast>);
}
enum OpenClassState {
  FindNs(namespaceCode:Ast, name:String);
  Open(namespace:RClass, name:String);
}
enum SendState {
  Start(targetCode:Ast, message:String, argsCode:Array<Ast>);
  GetTarget(message:String, argsCode:Array<Ast>);
  EvalArgs(target:RObject, message:String, argsCode:Array<Ast>, args:Array<RObject>);
  Invoke(target:RObject, message:String, args:Array<RObject>);
  End;
}
enum SelfState {
  Start;
}
enum ValueState {
  Immediate(value:RObject);
  Function(fn:Void->RObject);
}
