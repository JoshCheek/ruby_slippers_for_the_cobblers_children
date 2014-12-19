package ruby;
import ruby.ds.Ast;
using Lambda;

class TestParser extends ruby.support.TestCase {
  public function assertParses(rubyCode:String, expected:Ast, ?c:haxe.PosInfos) {
    assertEquals(Std.string(expected),
                 Std.string( ruby.ParseRuby.fromCode(rubyCode) )
                );
  }

  // literals
  public function testSpecialObjects() {
    assertParses(    "nil;    true;    false;    self",
      AstExpressions([AstNil, AstTrue, AstFalse, AstSelf])
    );
  }

  public function testIntegers() {
    assertParses(               "1;             -123",
      AstExpressions([AstInteger(1), AstInteger(-123)])
    );
  }

  public function testFloat() {
    assertParses("-12.34", AstFloat(-12.34));
    // assertParses("1.0", AstFloat(1.0)); // FIXME: it renders `AstFloat(1.0)` to string as `AstFloat(1)`
  }

  public function testStrings() {
    assertParses("'abc'", AstString("abc"));
  }

  // variables
  public function testVariables() {
    assertParses("
      a = 1
      a
      A
      @a = 1
      @a",
      AstExpressions([
        AstSetLocalVariable("a", AstInteger(1)),
        AstGetLocalVariable("a"),
        AstConstant(AstNil, "A"), // going w/ nil b/c that's what comes in, but kinda seems like the parser should make this a CurrentNamespace node or something
        AstSetInstanceVariable("@a", AstInteger(1)),
        AstGetInstanceVariable("@a"),
      ])
    );
  }

  // sending messages
  public function testSendingMessages() {
    assertParses("true.something(false)", AstSend(AstTrue, "something", [AstFalse]));
  }

  // class and module definitions
  public function testClassAndModuleDefinitions() {
    assertParses("
      class A
        class B::C < D
        end
      end
      ",
      AstClass(
        AstConstant(AstNil, "A"), // name
        AstNil,                   // superclass
        AstClass(                 // body
          AstConstant(AstConstant(AstNil, "B"), "C"),
          AstConstant(AstNil, "D"),
          AstNil
        )
      )
    );
  }

  // method definitions
  public function testAll() {
    assertParses("
      def bland_method; end
      def method_with_args_and_body(arg)
        true
      end
      ",
      AstExpressions([
        AstMethodDefinition("bland_method", [], AstNil),
        AstMethodDefinition(
          "method_with_args_and_body",
          [AstRequiredArg("arg")],
          AstTrue
        ),
      ])
    );
  }

}
