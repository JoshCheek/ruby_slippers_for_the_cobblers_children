package ruby2.ast;

typedef StringAstAttributes = {
  > Ast.AstAttributes,
  var value:String;
}

class StringAst extends Ast {
  public var value:String;
  public function new(attributes:StringAstAttributes) {
    this.value = attributes.value;
    super(attributes);
  }
  override public function get_isString() return true;
  override public function toString() return this;
}
