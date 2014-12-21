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

  // ignoring args for now b/c I'm tired and shit
  // mirrors: AstSend(target:Ast, message:String, args:Array<Ast>);
  // Send(target:EvaluationState, message:String);

  ConstantName(value:ConstantNameValue);

  // AstClass(nameLookup:Ast, superclass:Ast, body:Ast);
}

enum EvaluationListValue {
  Cons(current:EvaluationState, next:EvaluationListValue);
  ListEnd;
}

// AstConstant(namespace:Ast, name:String);
// this is stupid, b/c I can still do ConstantName(ImplicitNamespace), which makes no sense.
// really it should be
//   ConstantName((ConstantName|Implicit|Toplevel), name:String)
// but ADT will treat ConstantName as a value, so I can't do that
enum ConstantNameValue {
  Lookup(namespace:ConstantNameValue, name:String);
  ImplicitNamespace;
}
