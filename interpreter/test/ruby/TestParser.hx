package ruby;
import ruby.ds.Ast;
using Lambda;

class TestParser extends ruby.support.TestCase {
  function assertParses(rubyCode:String, expected:Ast, ?c:haxe.PosInfos) {
    assertEquals(Std.string(expected),
                 Std.string( ruby.ParseRuby.fromCode(rubyCode) )
                );
  }

  // literals
  function testSpecialObjects() {
    assertParses(    "nil;    true;    false;    self",
      Exprs([Nil, True, False, Self])
    );
  }

  function testIntegers() {
    assertParses(               "1;             -123",
      Exprs([Integer(1), Integer(-123)])
    );
  }

  function testFloat() {
    assertParses("-12.34", Float(-12.34));
    // assertParses("1.0", Float(1.0)); // FIXME: it renders `Float(1.0)` to string as `Float(1)`
  }

  function testStrings() {
    assertParses("'abc'", String("abc"));
  }

  // variables
  function testVariables() {
    assertParses("
      a = 1
      a
      A
      @a = 1
      @a",
      Exprs([
        SetLvar("a", Integer(1)),
        GetLvar("a"),
        Constant(Nil, "A"), // going w/ nil b/c that's what comes in, but kinda seems like the parser should make this a CurrentNamespace node or something
        SetIvar("@a", Integer(1)),
        GetIvar("@a"),
      ])
    );
  }

  // sending messages
  function testSendingMessages() {
    assertParses("true.something(false)", Send(True, "something", [False]));
  }

  // class and module definitions
  function testClassAndModuleDefinitions() {
    assertParses("
      class A
        class B::C < D
        end
      end
      ",
      Class(
        Constant(Nil, "A"), // name
        Nil,                   // superclass
        Class(                 // body
          Constant(Constant(Nil, "B"), "C"),
          Constant(Nil, "D"),
          Nil
        )
      )
    );
  }

  // method definitions
  function testMethodDefinitions() {
    assertParses("
      def bland_method; end
      def method_with_args_and_body(arg)
        true
      end
      ",
      Exprs([
        Def("bland_method", [], Nil),
        Def(
          "method_with_args_and_body",
          [RequiredArg("arg")],
          True
        ),
      ])
    );
  }

}
