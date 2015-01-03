// https://github.com/HaxeFlixel/flixel/blob/914a3478e9bfef824713301d5e97404aaea95af8/flixel/FlxGame.hx#L570

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;

// haxe/macro/Type.hx
class Omg {
  macro public static function build(e:Expr):Expr {
    // var constructor : Null<Ref<ClassField>>;
    // typedef Ref<T> = {
    // 	public function get() : T;
    // 	public function toString() : String;
    // }
    // typedef ClassField = {
    // 	var name : String;
    // 	var type : Type;
    // 	var isPublic : Bool;
    // 	var params : Array<TypeParameter>;
    // 	var meta : MetaAccess;
    // 	var kind : FieldKind;
    // 	function expr() : Null<TypedExpr>;
    // 	var pos : Expr.Position;
    // 	var doc : Null<String>;
    // }
    // typedef TypedExpr = {
    // 	expr: TypedExprDef,
    // 	pos: Expr.Position,
    // 	t: Type
    // }
    // enum TypedExprDef {
    // 	TConst(c:TConstant);
    // 	TLocal(v:TVar);
    // 	TArray(e1:TypedExpr, e2:TypedExpr);
    // 	TBinop(op:Expr.Binop, e1:TypedExpr, e2:TypedExpr);
    // 	TField(e:TypedExpr, fa:FieldAccess);
    // 	TTypeExpr(m:ModuleType);
    // 	TParenthesis(e:TypedExpr);
    // 	TObjectDecl(fields:Array<{name:String, expr:TypedExpr}>);
    // 	TArrayDecl(el:Array<TypedExpr>);
    // 	TCall(e:TypedExpr, el:Array<TypedExpr>);
    // 	TNew(c:Ref<ClassType>, params: Array<Type>, el:Array<TypedExpr>);
    // 	TUnop(op:Expr.Unop, postFix:Bool, e:TypedExpr);
    // 	TFunction(tfunc:TFunc);
    // 	TVar(v:TVar, expr:Null<TypedExpr>);
    // 	TBlock(el:Array<TypedExpr>);
    // 	TFor(v:TVar, e1:TypedExpr, e2:TypedExpr);
    // 	TIf(econd:TypedExpr, eif:TypedExpr, eelse:Null<TypedExpr>);
    // 	TWhile(econd:TypedExpr, e:TypedExpr, normalWhile:Bool);
    // 	TSwitch(e:TypedExpr, cases:Array<{values:Array<TypedExpr>, expr:TypedExpr}>, edef:Null<TypedExpr>);
    // 	TTry(e:TypedExpr, catches:Array<{v:TVar, expr:TypedExpr}>);
    // 	TReturn(e:Null<TypedExpr>);
    // 	TBreak;
    // 	TContinue;
    // 	TThrow(e:TypedExpr);
    // 	TCast(e:TypedExpr, m:Null<ModuleType>);
    // 	TMeta(m:Expr.MetadataEntry, e1:TypedExpr);
    // 	TEnumParameter(e1:TypedExpr, ef:EnumField, index:Int);
    // }

    var ref      = Context.getLocalClass();
    var tmp      = ref.get();
    var newKlass : haxe.macro.Type.ClassType = Reflect.copy(tmp);
    newKlass.init = {
    	expr: TConst(),
    	pos:  Context.currentPos(),
    	t:    FoilMetaprogramming,
    }

    // newKlass.init = {
    //   toString: function() { return "OVERRIDDEN CONSTRUCTOR"; },
    //   get: function() {
    //     var realClassField = newKlass.constructor.get();
    //     var newClassField  = Reflect.copy(realClassField);
    //     // newClassField.expr =
    //     //   e
    //     //   ;
    //     return newClassField;
    //   },
    // }

    // { expr => EConst(CIdent(FoilMetaprogramming)), pos => #pos(FoilMetaprogramming.hx:91: characters 14-17) }
    return {expr: EConst(Cident(FoilMetaprogramming)), pos: Context.currentPos()};
  }
}

class FoilMetaprogramming {
  public function new() {
    trace("Original new!");
  }

  // macro static function
  public static function main() {
    Omg.build(trace("omg"));
  }
}
