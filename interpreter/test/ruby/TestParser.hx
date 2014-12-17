package ruby;
import ruby.ds.Ast;
using Lambda;

class TestParser extends haxe.unit.TestCase {
  public function assertParses(rubyCode:String, expected:Ast, ?c:haxe.PosInfos) {
    assertEquals(Std.string(expected),
                 Std.string( ruby.ParseRuby.fromCode(rubyCode) )
                );
  }

  // because integration tests are so expensive, consolidate them into one large test
  public function testAll() {
    assertParses("
      # literals
        # special objects
          nil
          true
          false
          self
        # Numeric
          # Integer
            1
            -123
          # Bignum
          # Float
            -12.34
          # Complex
          # Rational
        # String
          'abc'
      # variables
        a = 1
        a
        A
        @a = 1
        @a
      # sending messages
        true.something(false)
      # class/module definitions
        class A
          class B::C < D
          end
        end
      # method definitions
        def bland_method; end
        def method_with_args_and_body(arg)
          true
        end
      ",
      AstExpressions([
        // literals
          // special objects
          AstNil,
          AstTrue,
          AstFalse,
          AstSelf,
          // Numeric
            // Fixnum
              AstInteger(1),
              AstInteger(-123),
            // Bignum
            // Float
              // 1.0 ->  Float(1.0) FIXME: gets cast to Int b/c of confusion on types >.<
              AstFloat(-12.34),
            // Complex
            // Rational
          // String
            AstString("abc"),
        // variables
          AstSetLocalVariable("a", AstInteger(1)),
          AstGetLocalVariable("a"),
          AstConstant(AstNil, "A"), // going w/ nil b/c that's what comes in, but kinda seems like the parser should make this a CurrentNamespace node or something
          AstSetInstanceVariable("@a", AstInteger(1)),
          AstGetInstanceVariable("@a"),
        // sending messages
          AstSend(AstTrue, "something", [AstFalse]),
        // class/module definitions
          AstClass(AstConstant(AstNil, "A"),
                AstNil,
                AstClass(AstConstant(AstConstant(AstNil, "B"), "C"),
                      AstConstant(AstNil, "D"),
                      AstNil
                )
          ),
        // method definitions
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
