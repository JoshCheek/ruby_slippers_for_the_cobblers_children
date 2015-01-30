package ruby2.ast;

typedef SetLvarAstAttributes = {
  > Ast.AstAttributes,
  var name  : String;
  var value : Ast;
}

class SetLvarAst extends Ast {
  public var name  : String;
  public var value : Ast;
  public function new(attributes:SetLvarAstAttributes) {
    this.name  = attributes.name;
    this.value = attributes.value;
    super(attributes);
  }
  override public function get_isSetLvar() return true;
  override public function toSetLvar() return this;
}
