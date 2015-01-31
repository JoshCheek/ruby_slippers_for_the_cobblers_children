package ruby4.ast;

typedef IntegerAstAttributes = {
  > Ast.AstAttributes,
  var value:Int;
}

class IntegerAst extends Ast {
  public var value:Int;
  public function new(attributes:IntegerAstAttributes) {
    this.value = attributes.value;
    super(attributes);
  }
  override public function get_isInteger() return true;
  override public function toInteger() return this;
}
