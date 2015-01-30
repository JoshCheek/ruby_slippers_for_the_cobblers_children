package ruby2.ast;

typedef ExprsAstAttributes = {
  > Ast.AstAttributes,
  var expressions:Array<Ast>;
}

class ExprsAst extends Ast {
  var expressions : Array<Ast>;
  public function new(attributes:ExprsAstAttributes) {
    this.expressions = attributes.expressions;
    super(attributes);
  }
  override public function get_isExprs() return true;
  override public function toExprs() return this;

  public var length(get, never):Int;
  function get_length() return expressions.length;

  public function get(index:Int) {
    return expressions[index];
  }
}
