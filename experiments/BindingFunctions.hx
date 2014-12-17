import haxe.macro.Context;

using haxe.rtti.Meta;
using haxe.macro.Expr;
using haxe.macro.ExprTools;

/*
  helpful example:
    https://gist.github.com/Lerc/6056075268a46050b232

  Expr is defined here:
    https://github.com/HaxeFoundation/haxe/blob/1feef0935c73147a91444e04cb94b81f9c9b5d6f/std/haxe/macro/Expr.hx#L172-175

  if last argument is Array<Expr>, then the macro can take however many args it wants e.g.
    [{ expr => EBlock([{ expr => EConst(CInt(1)), pos  => #pos(BindingFunctions.hx:19: characters 24-25)}]),
       pos  => #pos(BindingFunctions.hx:19: characters 22-28)
    }]
*/

class Spr { public var x:Int; }
class A extends Spr {
  public function new() { x = 1; }
}

class B extends Spr {
  public function new() { x = 1; }
  dynamic public function get_x():Int { return 9; }
}

@:tests(
  "it turns @test into a test",
  function() {
    assertTrue(true);
  },

  "it passes failing tests that are expected to fail",
  function() {
    assertFalse(false);
  },

  "if any test is focused, it only runs that test",
  function() {
    assertTrue(true);
  },

  "it identifies tests tagged with a given tag",
  function() {
    assertTrue(true);
  }
)
class C { }


class BindingFunctions {
  static var x = 1;

  macro static public function build():Array<Expr> {
    trace(Meta.getType(C));
    trace(Meta.getFields(C));
    trace(Meta.getStatics(C));
    return [];
  }

  public static function main() {
    trace("PRE");
    var a = new A();
    var b = new B();
    var f = rebind(a, { 1; x; }); // I want this to do Class.new(a.class) { define_method(:some_name) { 1; x } } in Ruby parlance, but can't figure out how to do it yet, it only passes b/c it omits the block from the output
    trace("POST");
  }

  macro static function rebind(self:Expr, statements:Array<Expr>):Expr {
    trace(self.toString());
    trace(statements.toString());
    // trace(Type.typeof(Context.getLocalModule()));
    return self;
  }
}
