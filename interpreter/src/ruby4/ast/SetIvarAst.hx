package ruby4.ast;

typedef SetIvarAstAttributes = {
  > Ast.AstAttributes,
  var name  : String;
  var value : Ast;
}

class SetIvarAst extends Ast {
  public var name  : String;
  public var value : Ast;
  public function new(attributes:SetIvarAstAttributes) {
    this.name  = attributes.name;
    this.value = attributes.value;
    super(attributes);
  }
  override public function get_isSetIvar() return true;
  override public function toSetIvar() return this;
}
