package ruby3.ast;

class TrueAst extends Ast {
  override public function get_isTrue() return true;
  override public function toTrue() return this;
}
