package ruby2.ast;

typedef FloatAstAttributes = {
  > Ast.AstAttributes,
  var value:Float;
}

class FloatAst extends Ast {
  public var value:Float;
  public function new(attributes:FloatAstAttributes) {
    this.value = attributes.value;
    super(attributes);
  }
  override public function get_isFloat() return true;
  override public function toFloat() return this;
}
