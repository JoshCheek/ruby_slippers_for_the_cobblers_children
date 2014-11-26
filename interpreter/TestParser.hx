// https://github.com/HaxeFoundation/haxe/blob/development/std/haxe/unit/TestCase.hx


// https://github.com/whitequark/parser/blob/master/doc/AST_FORMAT.md
enum RubyAst {
  Nil;
  True;
  False;
  Integer(value:Int);
  Float(value:Float);
  // String(value:String);
  Undefined(code:Dynamic);
}

class TestParser extends haxe.unit.TestCase {
  // how do i make a compound type?
  public function parse(rawCode:String):RubyAst {
    var astFor     = new sys.io.Process('../bin/ast_for', [rawCode]);
    var rawJson    = "";
    try { rawJson += astFor.stdout.readLine(); } catch (ex:haxe.io.Eof) { /* no op */ }
    var json       = haxe.Json.parse(rawJson);
    // trace(rawCode);
    // trace(rawJson);
    // trace(json);
    var works = switch(json.type) {
      case "nil"    : Nil;
      case "true"   : True;
      case "false"  : False;
      case "integer": Integer(json.value);
      case "float"  : Float(json.value);
      // case "string" : String(json.value);
      case _        : Undefined(json);
    }
    return works;
  }

  public function assertParses(rubyCode:String, expected:RubyAst, ?c:haxe.PosInfos) {
    assertEquals(Std.string(expected), Std.string(parse(rubyCode)));
  }

  public function testNil()     assertParses("nil", Nil);
  public function testTrue()    assertParses("true", True);
  public function testFalse()   assertParses("false", False);
  public function testInteger() {
    assertParses("1",    Integer(1));
    assertParses("-123", Integer(-123));
  }
  public function testFloat() {
    // assertParses('1.0',    Float(1.0)); //FIXME: gets cast to Int b/c of confusion on types >.<
    assertParses('-12.34', Float(-12.34));
  }

  //TODO: Complex and Rational

  public function testString() {
    // assertParses("'abc'", String("abc"));
  }
}
