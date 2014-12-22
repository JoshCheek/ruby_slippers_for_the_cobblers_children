package ruby.ds;

// https://github.com/whitequark/parser/blob/master/doc/AST_FORMAT.md
enum Ast {
  Nil;
  True;
  False;
  Self;
  Integer(value:Int);
  Float(value:Float);
  String(value:String);
  Exprs(expressions:Array<Ast>);
  Undefined(code:Dynamic);
  SetLocalVariable(name:String, value:Ast);
  GetLocalVariable(name:String);
  SetInstanceVariable(name:String, value:Ast);
  GetInstanceVariable(name:String);
  Send(target:Ast, message:String, args:Array<Ast>);
  Constant(namespace:Ast, name:String);
  Class(nameLookup:Ast, superclass:Ast, body:Ast);
  MethodDefinition(name:String, args:Array<Ast>, body:Ast);
  RequiredArg(name:String);
}
