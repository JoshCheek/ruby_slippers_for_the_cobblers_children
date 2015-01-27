// This does not work, was trying it out b/c I saw this fn:
// https://github.com/muguangyi/haxe/blob/8f77ba08b987a6121534abc8fe87d739e5c27c51/std/cs/internal/Function.hx#L81

class ObjectEquality {
  var i:Int;

  public function new(i)
    this.i = i;

  public function Equals(obj:ObjectEquality)
    this.i == obj.i;

  public static function main()
    trace(new ObjectEquality(1) == new ObjectEquality(1));
}
