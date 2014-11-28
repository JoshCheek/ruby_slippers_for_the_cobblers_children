class TestInterpreter extends haxe.unit.TestCase {
  // https://github.com/JoshCheek/ruby_object_model_viewer/tree/5204eb089329b387353da0c25016328c55fba369/haxe-testing-example
  //   simple example of a test suite
  //
  // http://api.haxe.org/haxe/unit/index.html
  //   test suite api
  //
  // http://api.haxe.org/
  //   language api

  // this only finds the json if you are in the current dir (e.g. via rake)
  // not sure how to get the location of this file, specifically
  var filepath = "../example-json-to-evaluate.json";

  private function forCode(rawCode:String):RubyInterpreter {
    var ast         = ParseRuby.fromCode(rawCode);
    var interpreter = new RubyInterpreter();
    interpreter.addCode(ast);
    return interpreter;
  }

  private function assertLooksKindaSimilar<T>(a: T, b:T):Void {
    assertEquals(Std.string(a), Std.string(b));
  }

  public function testItsCurrentExpressionIsNilByDefault() {
    // TODO: What does this look like?
    assertTrue(true);
  }

  public function testItEvaluatesAStringLiteral() {
    var rbstr       = new RubyString().withValue("Josh").withDefaults();
    var interpreter = forCode('"Josh"');
    interpreter.drain();
    assertLooksKindaSimilar(rbstr, interpreter.currentExpression());
  }

  public function testItSetsAndGetsLocalVariables() {
    // { type: "expressions",
    //   expressions: [
    //     { type: "set_local_variable",
    //       name: "a",
    //       value: { "value": "b", "type": "string" }
    //     },
    //     { type: "string",
    //       value: "c"
    //     },
    //     { type: "get_local_variable",
    //       name: "a"
    //     }
    //   ]
    // }
    var interpreter = forCode("a = 'b'\n'c'\n a");
    assertLooksKindaSimilar(new RubyString().withDefaults().withValue('b'), interpreter.drain());
    assertLooksKindaSimilar(new RubyString().withDefaults().withValue('c'), interpreter.drain());
    assertLooksKindaSimilar(new RubyString().withDefaults().withValue('b'), interpreter.drain());
  }


  /**
  need to be able to eval:
    local vars
      get/set
    constant lookup
    class definition
    method definition
      required args
    method invocation
      with args
    ivars
      get/set

  need:
    track internal printing
    stack

  classes:
    name
    namespace

  objects:
    main

  necessary classes:
    Object
      #puts <-- for now
      TOPLEVEL_BINDING
    String
  */



  // The json structure:
  // {"type"=>"expressions",
  //  "expressions"=>
  //   [{"type"=>"class",
  //     "name_lookup"=>{"type"=>"constant", "namespace"=>nil, "name"=>"User"},
  //     "superclass"=>nil,
  //     "body"=>
  //      {"type"=>"expressions",
  //       "expressions"=>
  //        [{"type"=>"method_definition",
  //          "args"=>[{"type"=>"required_arg", "name"=>"name"}],
  //          "body"=>
  //           {"type"=>"send",
  //            "target"=>{"type"=>"self"},
  //            "message"=>"name=",
  //            "args"=>[{"type"=>"get_local_variable", "name"=>"name"}]}},
  //         {"type"=>"method_definition",
  //          "args"=>[],
  //          "body"=>{"type"=>"get_instance_variable", "name"=>"@name"}},
  //         {"type"=>"method_definition",
  //          "args"=>[{"type"=>"required_arg", "name"=>"name"}],
  //          "body"=>
  //           {"type"=>"set_instance_variable",
  //            "name"=>"@name",
  //            "value"=>{"type"=>"get_local_variable", "name"=>"name"}}}]}}
  //    ,{"type"=>"set_local_variable",
  //     "name"=>"user",
  //     "value"=>
  //      {"type"=>"send",
  //       "target"=>{"type"=>"constant", "namespace"=>nil, "name"=>"User"},
  //       "message"=>"new",
  //       "args"=>[{"type"=>"string", "value"=>"Josh"}]}}
  //    ,{"type"=>"send",
  //     "target"=>nil,
  //     "message"=>"puts",
  //     "args"=>
  //      [{"type"=>"send",
  //        "target"=>{"type"=>"get_local_variable", "name"=>"user"},
  //        "message"=>"name",
  //        "args"=>[]}]}]}
  public function _testAacceptance1() {
    var interpreter = forCode('
      class User
        def initialize(name)
          self.name = name
        end

        def name
          @name
        end

        def name=(name)
          @name = name
        end
      end

      user = User.new("Josh")
      puts user.name'
    );

    interpreter.drainAll();

    // the code successfully printed
    // ... eventually switch to `assert_equal "Josh", stdout.string`
    assertEquals("Josh\n", interpreter.printedInternally());

    // it defined the class
    var userClass = interpreter.lookupClass('User');
    assertEquals('User', userClass.name);
    assertEquals('[initialize,name,name=]', Std.string(userClass.instanceMethods));

    // it is tracking the instance
    assertEquals(1, interpreter.eachObject(userClass).length);
  }
}
