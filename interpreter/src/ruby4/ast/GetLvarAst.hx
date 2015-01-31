package ruby4.ast;

typedef GetLvarAstAttributes = {
  > Ast.AstAttributes,
  var name:String;
}

class GetLvarAst extends Ast {
  public var name:String;
  public function new(attributes:GetLvarAstAttributes) {
    this.name = attributes.name;
    super(attributes);
  }
  override public function get_isGetLvar() return true;
  override public function toGetLvar() return this;
}
