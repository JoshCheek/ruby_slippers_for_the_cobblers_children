package ruby3.ast;

class SelfAst extends Ast {
  override public function get_isSelf() return true;
  override public function toSelf() return this;
}
