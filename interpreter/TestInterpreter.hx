// in case I get annoyed and try to write my own test suite >.<
// var a = function(x) { return x + 1; };

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

  private function forJsonCode(rawJson:String, evalType='expression'):RubyInterpreter {
    // FOR THE FUTURE
    // stdout      = StringIO.new
    // interpreter = Interpreter.new(stdout: stdout)
    var interpreter = new RubyInterpreter();
    interpreter.addCode(haxe.Json.parse(rawJson));

    if(evalType == 'expression')
      interpreter.drain();
    else if(evalType == 'all')
      interpreter.evalAll();
    else if(evalType == 'none')
      null; // no op

    return interpreter;
  }

  private function forCode(rawCode:String, evalType='expression'):RubyInterpreter {
    // this, stupidly, also depends on CWD
    var astFor  = new sys.io.Process('../bin/ast_for', [rawCode]);
    var rawJson = "";
    try { rawJson += astFor.stdout.readLine(); } catch (ex:haxe.io.Eof) { /* no op */ }
    return forJsonCode(rawJson);
  }

  private function assertLooksKindaSimilar<T>(a: T, b:T):Void {
    assertEquals(Std.string(a), Std.string(b));
  }

  public function testItEvaluatesAStringLiteral() {
    var rbstr       = new RubyString().withDefaults().withValue("Josh");
    var interpreter = forJsonCode('{"type":"string", "value":"Josh"}');
    assertLooksKindaSimilar(rbstr, interpreter.currentExpression());
  }

  public function testItSetsAndGetsLocalVariables() {
    // { type: "expressions"
    //   expressions: [
    //     { type: "set_local_variable"
    //       name: "a",
    //       value: { "value": "b", "type": "string" },
    //     },
    //     { type: "string"
    //       value: "c",
    //     },
    //     { type: "get_local_variable"
    //       name: "a",
    //     }
    //   ],
    // }
    var interpreter = forCode("a = 'b'\n'c'\n a", 'none');
    assertLooksKindaSimilar(new RubyString().withDefaults().withValue('b'), interpreter.evalNextExpression());
    assertLooksKindaSimilar(new RubyString().withDefaults().withValue('c'), interpreter.evalNextExpression());
    assertLooksKindaSimilar(new RubyString().withDefaults().withValue('b'), interpreter.evalNextExpression());
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



  /** CODE:
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
    puts user.name
  */

  // "JSON":
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
    var interpreter = forJsonCode(sys.io.File.getContent(filepath), 'all');
    var interpreter = new RubyInterpreter();

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
