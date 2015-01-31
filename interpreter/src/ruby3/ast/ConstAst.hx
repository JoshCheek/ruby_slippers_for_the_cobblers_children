package ruby3.ast;

typedef ConstAstAttributes = {
  > Ast.AstAttributes,
  var name : String;
  var ns   : Ast;
}

class ConstAst extends Ast {
  public var name : String;
  public var ns   : Ast;
  public function new(attributes:ConstAstAttributes) {
    this.name = attributes.name;
    this.ns   = attributes.ns;
    super(attributes);
  }
  override public function get_isConst() return true;
  override public function toConst() return this;
}
