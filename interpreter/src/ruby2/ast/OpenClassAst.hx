package ruby2.ast;

typedef OpenClassAstAttributes = {
  > Ast.AstAttributes,
  var ns         : Ast;
  var superclass : Ast;
  var body       : Ast;
}

class OpenClassAst extends Ast {
  public var ns         : Ast;
  public var superclass : Ast;
  public var body       : Ast;
  public function new(attributes:OpenClassAstAttributes) {
    this.ns         = attributes.ns;
    this.superclass = attributes.superclass;
    this.body       = attributes.body;
    super(attributes);
  }
  override public function get_isOpenClass() return true;
  override public function toOpenClass() return this;
}
