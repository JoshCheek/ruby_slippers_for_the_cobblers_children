package ruby.ds;
import  ruby.ds.objects.RObject;
import  ruby.ds.objects.RClass;
import  ruby.ds.objects.RBinding;

// TODO: remove world, and have Interpreter be an attribute of World
// ie "namespacing" chunks of related data
typedef Interpreter = {
  public var world : ruby.ds.World;
  public var stack : List<StackFrame>;
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
  // lookin good
  SetLocal  (state:SetLocalState);
  GetConst  (state:GetConstState);
  Exprs     (state:ExprsState);
  OpenClass (state:OpenClassState);

  // in need of state:
  Send(s:{state:String, targetCode:Ast, target:RObject, message:String, argsCode:Array<Ast>, args:Array<RObject>});

  //astate would add consistency:
  Self;
  Value(obj:RObject);
  PendingValue(fn:Void->RObject);
  GetLocal(name:String);
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
