package ruby.ds;

// https://github.com/whitequark/parser/blob/master/doc/AST_FORMAT.md
enum Ast {
  None; // ie there is no ast here

  Nil;
  True;
  False;
  Self;
  Integer(value:Int);
  Float(value:Float);
  String(value:String);
  Exprs(expressions:Array<Ast>);
  Undefined(code:Dynamic);
  SetLvar(name:String, value:Ast);
  GetLvar(name:String);
  SetIvar(name:String, value:Ast);
  GetIvar(name:String);
  Send(target:Ast, message:String, args:Array<Ast>);
  Constant(namespace:Ast, name:String);
  Class(nameLookup:Ast, superclass:Ast, body:Ast);
  Def(name:String, args:Array<Ast>, body:Ast);
  RequiredArg(name:String);
}
