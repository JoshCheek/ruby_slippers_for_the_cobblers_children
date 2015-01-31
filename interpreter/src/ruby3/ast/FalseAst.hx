package ruby3.ast;

class FalseAst extends Ast {
  override public function get_isFalse() return true;
  override public function toFalse() return this;
}
