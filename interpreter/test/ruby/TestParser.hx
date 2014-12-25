package ruby;
import ruby.ds.Interpreter;
using Lambda;

class TestParser extends ruby.support.TestCase {
  function assertParses(rubyCode:String, expected:ExecutionState, ?c:haxe.PosInfos) {
    var actual = ruby.ParseRuby.fromCode(rubyCode);
    assertEquals(Std.string(expected), Std.string(actual), c);
  }

  // literals
  function testSpecialObjects() {
    assertParses(    "nil;    true;    false;    self",
      Exprs(Start([Nil, True, False, Self]))
    );
  }

  function testIntegers() {
    assertParses(               "1;             -123",
      Exprs(Start([Integer(1), Integer(-123)]))
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
      Exprs(Start([
        SetLvar(FindRhs("a", Integer(1))),
        GetLvar(Name("a")),
        Const(GetNs(Default, "A")), // going w/ nil b/c that's what comes in, but kinda seems like the parser should make this a CurrentNamespace node or something
        SetIvar(FindRhs("@a", Integer(1))),
        GetIvar(Name("@a")),
      ]))
    );
  }

  // sending messages
  function testSendingMessages() {
    assertParses("true.something(false)", Send(Start(True, "something", [False])));
  }

  // class and module definitions
  function testClassAndModuleDefinitions() {
    assertParses("
      class A
        class B::C < D
        end
      end
      ",
      OpenClass(GetNs(
        Const(GetNs(Default, "A")), // name
        Default,                    // superclass
        OpenClass(GetNs(            // body
          Const(GetNs(Const(GetNs(Default, "B")), "C")),
          Const(GetNs(Default, "D")),
          Default
        ))
      ))
    );
  }

  // method definitions
  function testMethodDefinitions() {
    assertParses("
      def bland_method; end
      def method_with_args_and_body(req, *rst)
        true
      end
      ",
      Exprs(Start([
        Def(Start("bland_method", [], Default)),
        Def(Start(
          "method_with_args_and_body",
          [Required("req"), Rest("rst")],
          True
        )),
      ]))
    );
  }

}
