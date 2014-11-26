using Lambda;

// https://github.com/whitequark/parser/blob/master/doc/AST_FORMAT.md
enum RubyAst {
  Nil;
  True;
  False;
  Integer(value:Int);
  Float(value:Float);
  String(value:String);
  Expressions(expressions:Array<RubyAst>);
  Undefined(code:Dynamic);
}

class TestParser extends haxe.unit.TestCase {
  // how do i make a compound type?
  public function parse(rawCode:String):RubyAst {
    var astFor       = new sys.io.Process('../bin/ast_for', [rawCode]);
    var rawJson      = "";
    try { rawJson += astFor.stdout.readLine(); } catch (ex:haxe.io.Eof) { /* no op */ }
    var json:Dynamic = haxe.Json.parse(rawJson);
    // trace(rawCode);
    // trace(rawJson);
    // trace(json);
    return parseJson(json);
  }

  public function parseJson(ast:Dynamic):RubyAst {
    var rubyAst = switch(ast.type) {
      case "nil"         : Nil;
      case "true"        : True;
      case "false"       : False;
      case "integer"     : Integer(ast.value);
      case "float"       : Float(ast.value);
      case "string"      : String(ast.value);
      case "expressions" : Expressions(cast(ast.expressions, Array<Dynamic>).map(parseJson)); // This was pretty rough to figure out. Would be nice to have more docs on JSON
      case _             : Undefined(ast);
    }
    return rubyAst;
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

  //TODO: Complex and Rational, __FILE__

  public function testString() {
    assertParses("'abc'", String("abc"));
  }

  public function testExpressions() {
    assertParses('1;1', Expressions([Integer(1), Integer(1)]));
  }

  // public function testLocalVar() {
  //   assertParses("a=1;a",
  // }
}
