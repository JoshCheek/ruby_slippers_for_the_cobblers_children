package ruby.ds;

// https://github.com/whitequark/parser/blob/master/doc/AST_FORMAT.md
enum Ast {
  AstNil;
  AstTrue;
  AstFalse;
  AstSelf;
  AstInteger(value:Int);
  AstFloat(value:Float);
  AstString(value:String);
  AstExpressions(expressions:Array<Ast>);
  AstUndefined(code:Dynamic);
  AstSetLocalVariable(name:String, value:Ast);
  AstGetLocalVariable(name:String);
  AstSetInstanceVariable(name:String, value:Ast);
  AstGetInstanceVariable(name:String);
  AstSend(target:Ast, message:String, args:Array<Ast>);
  AstConstant(namespace:Ast, name:String);
  AstClass(nameLookup:Ast, superclass:Ast, body:Ast);
  AstMethodDefinition(name:String, args:Array<Ast>, body:Ast);
  AstRequiredArg(name:String);
}
