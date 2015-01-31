package ruby4.ast;

class DefaultAst extends Ast {
  override public function get_isDefault() return true;
  override public function toDefault() return this;
}
