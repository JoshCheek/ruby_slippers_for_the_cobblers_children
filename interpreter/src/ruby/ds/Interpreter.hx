package ruby.ds;
import  ruby.ds.Objects;

// World is of this type
typedef Interpreter = {
  public var stack             : List<StackFrame>;
  public var currentExpression : RObject;
}

typedef StackFrame = {
  public var binding : RBinding;
  public var state   : ExecutionState;
}

enum EvaluationResult {
  NoAction (newState:ExecutionState);
  Push     (newState:ExecutionState, code:ExecutionState, binding:RBinding);
  Pop      (returnValue:RObject);
}


enum ExecutionState {
  Default;
  Nil;
  Self;
  True;
  False;
  Integer   (value:Int);
  Float     (value:Float);
  String    (value:String);
  GetLvar   (state:GetLvarState);
  SetLvar   (state:SetLvarState);
  GetIvar   (state:GetIvarState);
  SetIvar   (state:SetIvarState);
  Const     (state:ConstState);
  Exprs     (state:ExprsState);
  OpenClass (state:OpenClassState);
  Send      (state:SendState);
  Value     (state:ValueState);
  Def       (state:DefState);
}
enum GetLvarState {
  Name(name:String);
}
enum SetLvarState {
  FindRhs(name:String, rhs:ExecutionState);
  SetLhs(name:String);
}
enum GetIvarState {
  Name(name:String);
}
enum SetIvarState {
  FindRhs(name:String, rhs:ExecutionState);
  SetLhs(name:String);
}
enum ConstState {
  GetNs(namespace:ExecutionState, name:String);
  Get(name:String);
}
enum ExprsState {
  Start(expressions:Array<ExecutionState>);
  Crnt(index:Int, expressions:Array<ExecutionState>);
}
enum OpenClassState {
  GetNs(namespaceCode:ExecutionState, superclassCode:ExecutionState, body:ExecutionState);
  GetSpr(name:String, superclassCode:ExecutionState, body:ExecutionState);
  Open(ns:RClass, name:String, body:ExecutionState);
  Body(klass:RClass, body:ExecutionState);
  Finished;
}
enum SendState {
  Start(targetCode:ExecutionState, message:String, argsCode:Array<ExecutionState>);
  GetTarget(message:String, argsCode:Array<ExecutionState>);
  EvalArgs(target:RObject, message:String, argsCode:Array<ExecutionState>, args:Array<RObject>);
  Invoke(target:RObject, message:String, args:Array<RObject>);
  End;
}
enum ValueState {
  Immediate(value:RObject);
  Function(fn:Void->RObject);
}
enum DefState {
  Start(name:String, args:Array<ArgType>, body:ExecutionState);
}
