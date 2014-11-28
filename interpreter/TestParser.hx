using Lambda;

class TestParser extends haxe.unit.TestCase {
  public function assertParses(rubyCode:String, expected:RubyAst, ?c:haxe.PosInfos) {
    assertEquals(Std.string(expected),
                 Std.string( ParseRuby.fromCode(rubyCode) )
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
      Expressions([
        // literals
          // special objects
          Nil,
          True,
          False,
          Self,
          // Numeric
            // Fixnum
              Integer(1),
              Integer(-123),
            // Bignum
            // Float
              // 1.0 ->  Float(1.0) FIXME: gets cast to Int b/c of confusion on types >.<
              Float(-12.34),
            // Complex
            // Rational
          // String
            String("abc"),
        // variables
          SetLocalVariable("a", Integer(1)),
          GetLocalVariable("a"),
          Constant(Nil, "A"), // going w/ nil b/c that's what comes in, but kinda seems like the parser should make this a CurrentNamespace node or something
          SetInstanceVariable("@a", Integer(1)),
          GetInstanceVariable("@a"),
        // sending messages
          Send(True, "something", [False]),
        // class/module definitions
          RClass(Constant(Nil, "A"),
                 Nil,
                 RClass(Constant(Constant(Nil, "B"), "C"),
                        Constant(Nil, "D"),
                        Nil
                 )
          ),
        // method definitions
          MethodDefinition("bland_method", [], Nil),
          MethodDefinition(
            "method_with_args_and_body",
            [RequiredArg("arg")],
            True
          ),
      ])
    );
  }

}
