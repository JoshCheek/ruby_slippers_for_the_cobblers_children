package ruby4.ast;

typedef GetIvarAstAttributes = {
  > Ast.AstAttributes,
  var name:String;
}

class GetIvarAst extends Ast {
  public var name:String;
  public function new(attributes:GetIvarAstAttributes) {
    this.name = attributes.name;
    super(attributes);
  }
  override public function get_isGetIvar() return true;
  override public function toGetIvar() return this;
}
