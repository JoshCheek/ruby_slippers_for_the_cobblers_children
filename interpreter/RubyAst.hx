// https://github.com/whitequark/parser/blob/master/doc/AST_FORMAT.md
enum RubyAst {
  Nil;
  True;
  False;
  Self;
  Integer(value:Int);
  Float(value:Float);
  String(value:String);
  Expressions(expressions:Array<RubyAst>);
  Undefined(code:Dynamic);
  SetLocalVariable(name:String, value:RubyAst);
  GetLocalVariable(name:String);
  SetInstanceVariable(name:String, value:RubyAst);
  GetInstanceVariable(name:String);
  Send(target:RubyAst, message:String, args:Array<RubyAst>);
  Constant(namespace:RubyAst, name:String);
  RClass(nameLookup:RubyAst, superclass:RubyAst, body:RubyAst);
  MethodDefinition(name:String, args:Array<RubyAst>, body:RubyAst);
  RequiredArg(name:String);
}
