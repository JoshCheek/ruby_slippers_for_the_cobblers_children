package;

import ruby.ParseRuby;
import ruby.RubyInterpreter;
import ruby.RubyString;
import ruby.RubyObject;
import ruby.RubyClass;

using ruby.LanguageGoBag;

class TestInterpreter extends haxe.unit.TestCase {
  // https://github.com/JoshCheek/ruby_object_model_viewer/tree/5204eb089329b387353da0c25016328c55fba369/haxe-testing-example
  //   simple example of a test suite
  //
  // http://api.haxe.org/haxe/unit/index.html
  //   test suite api
  //
  // http://api.haxe.org/
  //   language api

  private function forCode(rawCode:String):RubyInterpreter {
    var ast         = ParseRuby.fromCode(rawCode);
    var interpreter = new RubyInterpreter();
    interpreter.addCode(ast);
    return interpreter;
  }

  private function assertLooksKindaSimilar<T>(a: T, b:T, ?pos:haxe.PosInfos):Void {
    assertEquals(Std.string(a), Std.string(b), pos);
  }

  // we're ignoring fixnums and symbols for now
  public function testSpecialConstants() {
    var interpreter = forCode("nil\ntrue\nfalse\n");
    assertEquals(interpreter.rubyNil,   interpreter.drain());
    assertEquals(interpreter.rubyTrue,  interpreter.drain());
    assertEquals(interpreter.rubyFalse, interpreter.drain());
  }

  public function testItsCurrentExpressionIsNilByDefault() {
    var interpreter = new RubyInterpreter();
    assertEquals(interpreter.rubyNil, interpreter.currentExpression());
  }

  public function testItEvaluatesAStringLiteral() {
    var rbstr       = new RubyString("Josh");
    var interpreter = forCode('"Josh"');
    interpreter.drain();
    assertLooksKindaSimilar(interpreter.currentExpression(), rbstr);
  }

  private function rStrs(strs:Array<String>):Array<RubyString> {
    return strs.map(function(str) return new RubyString(str));
  }

  // ffs Array<Dynamic> ...I'm giving it fucking RubyString, which *is* a RubyObject!
  private function assertDrains(interpreter, objects:Array<Dynamic>, ?pos:haxe.PosInfos) {
    var drained:Array<RubyObject> = interpreter.drainAll();
    for(pair in objects.zip(drained).iterator())
      assertLooksKindaSimilar(pair.l, pair.r, pos);
    assertEquals(objects.length, drained.length, pos);
  }

  public function testItSetsAndGetsLocalVariables() {
    var interpreter = forCode("var1 = 'b'
                               'c'
                               var1
                               var2 = 'd'
                               var1 = 'e'
                               var2
                               var1
                              ");
    assertDrains(interpreter, rStrs(['b', 'b', 'c', 'b', 'd', 'd', 'e', 'e', 'd', 'e']));
  }

  public function testClasses() {
    var interpreter = forCode("
      class A
      end
    ");
    interpreter.drainAll();
    assertLooksKindaSimilar(interpreter.toplevelNamespace().getConstant("A"), new RubyClass("A"));
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
