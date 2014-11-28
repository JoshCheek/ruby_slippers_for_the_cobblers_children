using Lambda;

// TODO: Write a blog about parsing JSON in Haxe
// it doesn't seem to have good examples out there,
// and it took a while to figure this stuff out,
// probably people would appreciate it.

// https://github.com/whitequark/parser/blob/master/doc/AST_FORMAT.md
enum RubyAst {
  Nil;
  True;
  False;
  Self;
  Integer(value:Int);
  Float(value:Float);
  String(value:String);
  Expressions(expressions:Array<RubyAst>);
  Undefined(code:Dynamic);
  SetLocalVariable(name:String, value:RubyAst);
  GetLocalVariable(name:String);
  SetInstanceVariable(name:String, value:RubyAst);
  GetInstanceVariable(name:String);
  Send(target:RubyAst, message:String, args:Array<RubyAst>);
  Constant(namespace:RubyAst, name:String);
  RClass(nameLookup:RubyAst, superclass:RubyAst, body:RubyAst);
  MethodDefinition(name:String, args:Array<RubyAst>, body:RubyAst);
  RequiredArg(name:String);
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
    if(ast == null) return Nil;

    var rubyAst = switch(ast.type) {
      case "nil"                   : Nil;
      case "true"                  : True;
      case "false"                 : False;
      case "self"                  : Self;
      case "integer"               : Integer(ast.value);
      case "float"                 : Float(ast.value);
      case "string"                : String(ast.value);
      case "expressions"           : Expressions(parseJsonArray(ast.expressions));
      case "set_local_variable"    : SetLocalVariable(ast.name, parseJson(ast.value));
      case "get_local_variable"    : GetLocalVariable(ast.name);
      case "set_instance_variable" : SetInstanceVariable(ast.name, parseJson(ast.value));
      case "get_instance_variable" : GetInstanceVariable(ast.name);
      case "send"                  : Send(parseJson(ast.target), ast.message, parseJsonArray(ast.args));
      case "constant"              : Constant(parseJson(ast.namespace), ast.name);
      case "class"                 : RClass(parseJson(ast.name_lookup), parseJson(ast.superclass), parseJson(ast.body));
      case "method_definition"     : MethodDefinition(ast.name, parseJsonArray(ast.args), parseJson(ast.body));
      case "required_arg"          : RequiredArg(ast.name);
      case _                       : Undefined(ast);
    }
    return rubyAst;
  }

  private function parseJsonArray(array:Array<Dynamic>):Array<RubyAst> {
    return array.map(parseJson);
  }

  public function assertParses(rubyCode:String, expected:RubyAst, ?c:haxe.PosInfos) {
    assertEquals(Std.string(expected), Std.string(parse(rubyCode)));
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
