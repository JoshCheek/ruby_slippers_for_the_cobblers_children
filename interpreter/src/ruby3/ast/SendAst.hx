package ruby3.ast;

typedef SendAstAttributes = {
  > Ast.AstAttributes,
  var target    : Ast;
  var message   : String;
  var arguments : Array<Ast>;
}

class SendAst extends Ast {
  public var target    : Ast;
  public var message   : String;
  public var arguments : Array<Ast>;
  public function new(attributes:SendAstAttributes) {
    this.target    = attributes.target;
    this.message   = attributes.message;
    this.arguments = attributes.arguments;
    super(attributes);
  }
  override public function get_isSend() return true;
  override public function toSend() return this;
}
