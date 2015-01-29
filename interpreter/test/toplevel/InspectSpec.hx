package toplevel;

// TODO:
//   rename .call to .inspect so we can use it as a static extension
//   is it inspecting private fields right now? if so, don't
// Haven't tested these:
//   haxe.Int32
//   haxe.Int64
//   classes
//   the enum class
//   abstracts

typedef TypeDefedStruct0 = {}
typedef TypeDefedStruct1 = {x:Int}
typedef TypeDefedStruct2 = {x:Int, y:String}

enum FixtureEnum {
  KeyOne;
  KeyTwo;
  ZeroArgs;
  OneArg(a:String);
  TwoArgs(a:String, b:String);
}

class FixtureClassInspectArity0 {
  var str:String;
  public function new(str) this.str = str;
  public function inspect() return str;
}
class FixtureClassInspectArity1 {
  var str:String;
  public function new(str) this.str = str;
  public function inspect(_:Int) return str;
}



class InspectSpec {
  public static function inspectsTo(a:spaceCadet.Asserter, inspected:String, toInspect:Dynamic) {
    a.eq(inspected, Inspect.call(toInspect));
  }


  // the Neko core implementation has an attribute "r" ...kinda iffy, but w/e
  @:access(EReg.r)
  public static function getUnknown():Dynamic {
#if neko
    return ~/regex/.r;
#else
    throw("Figure out how to get one of these on whatever platform we're on");
#end
  }

  public static function describe(d:spaceCadet.Description) {
    d.describe("Inspect", function(d) {
      d.describe('on a type with an inspect function', function(d) {
        d.context('for a struct', function(d) {
          d.it("uses the inspect function, when it has 0 arity", function(a) {
            inspectsTo(a, "!!", {inspect: function() return "!!"});
          });
          d.it("ignores the inspect function, when it nonzero arity", function(a) {
            inspectsTo(a, "{inspect: function(??) { ?? }}", {inspect: function(_:Int) return "!!"});
          });
        });
        d.context('for an instance', function(d) {
          d.it("uses the inspect function, when it has arity 0", function(a) {
            inspectsTo(a, "!!", new FixtureClassInspectArity0("!!"));
          });
          d.it("ignores the inspect function, when it expects args", function(a) {
            a.pending("Apparently it can't figure out the class at runtime (Type.getClass returns null)");
            inspectsTo(a, "What goes here?", new FixtureClassInspectArity1("!!"));
          });
        });
        d.context('when inspect function raises an error', function(d) {
          d.it('does not swallow the error', function(a) {
            a.pending('Just ignoring this for now, b/c I\'m feeling like getting more done');
            // test one where inspect throws a string, and where it throws something other than a string
            // ...unless we find a way to not have to invoke it when we don't know if it's reasonable to do so
          });
        });
      });

      d.describe("on null", function(d) {
        d.it('inspects to "null"', function(a) {
          inspectsTo(a, "null", null);
        });
      });

      d.describe("on a Bool", function(d) {
        d.it('true -> "true"', function(a) {
          inspectsTo(a, "true", true);
        });
        d.it('false -> "false"', function(a) {
          inspectsTo(a, "false", false);
        });
      });

      d.describe("on an Int", function(d) {
        d.it("inspects to the literal", function(a) {
          inspectsTo(a, "0", 0);
          inspectsTo(a, "1", 1);
          inspectsTo(a, "-1", -1);
          inspectsTo(a, "1234567890", 1234567890);
          inspectsTo(a, "-1234567890", -1234567890);
        });
      });

      d.describe("on a Float", function(d) {
        d.it('appends .0 when there are no values to the RHS of the point', function(a) {
          inspectsTo(a, "0.0", 0.0);
          inspectsTo(a, "0.0", .0);
          inspectsTo(a, "1.0", 1.0);
          inspectsTo(a, "-1.0", -1.0);
        });

        d.it('displays normally when there are values to the RHS of the point', function(a) {
          inspectsTo(a, '123.456', 123.456);
          inspectsTo(a, '-123.456', -123.456);
        });

        d.it('reverts to scientific notation when the float is sufficiently large', function(a) {
          inspectsTo(a, '1e+50', 1e+50);
          inspectsTo(a, '1e+50', 1e50);
          inspectsTo(a, '1.23e+50', 1.23e+50);
          inspectsTo(a, '1.23e+50', 1.23e50);
          inspectsTo(a, '-1.23e+50', -1.23e50);
        });
      });

      d.describe("on String", function(d) {
        d.it("wraps strings in quotes and escapes them", function(a) {
          inspectsTo(a, '"a\\bc"', "a\x08c");
        });
        d.it("escapes double quotes to avoid delimiter confusion", function(a) {
          inspectsTo(a, "\"\\\"\"", '"');
        });
        d.it("escapes escapes -- you should be able to paste the result into a source file and get the un-inspected version", function(a) {
          inspectsTo(a, "\"\\\\\"", '\\');
        });
      });

      d.describe("on an array", function(d) {
        d.it("wraps the array in brackets", function(a) {
          inspectsTo(a, "[]", []);
        });
        d.it("inspects each element, separating them with commas", function(a) {
          inspectsTo(a, '["a"]', ["a"]);
          inspectsTo(a, '["a", "b"]', ["a", "b"]);
          inspectsTo(a, '[["a"], ["b"]]', [["a"], ["b"]]);
        });
      });

      d.describe("on a list", function(d) {
        d.it('inspects like a lisp list, with each of its elements inspected', function(a) {
          inspectsTo(a, '()', new List());
          var l = new List();
          l.push("a");
          inspectsTo(a, '("a")', l);
          l.push("x");
          inspectsTo(a, '("x", "a")', l);
        });
      });

      d.describe("on hashes", function(d) {
        d.it("inspects like the literal", function(a) {
          inspectsTo(a, '[]', []);
          inspectsTo(a, '["a" => "b"]', ["a" => "b"]);
          inspectsTo(a, '["a" => "b", "c" => "d"]', ["a" => "b", "c" => "d"]);
        });
        d.it("works for StringMap", function(a) {
          inspectsTo(a, '["a" => "b"]', ["a" => "b"]);
        });
        d.it("works for IntMap", function(a) {
          inspectsTo(a, '[1 => "a"]', [1 => "a"]);
        });
        d.it("works for ObjectMap", function(a) {
          inspectsTo(a, '[{a: 1} => 2]', [{a:1} => 2]);
        });
        d.it("works for EnumValueMap", function(a) {
          inspectsTo(a, '[KeyOne => 2]', [KeyOne => 2]);
        });
        d.it("works for WeakMap", function(a) {
          a.pending('I don\'t know how to get one of these');
        });
        d.it("works for EnumValueMap", function(a) {
          a.pending('Looks like another class that isn\'t in the publically released version');
          // var map:haxe.ds.UnsafeStringMap = ["constructor" => "c", "prototype" => "p"];
          // a.eq('["constructor" => "c", "prototype" => "p"]', inspect(map));
        });
      });

      d.describe("on an anonymous struct, it inspects each value", function(d) {
        d.it("inspects empty structs", function(a) {
          inspectsTo(a, "{}", {});
          inspectsTo(a, "{a: 1}", {a: 1});
          inspectsTo(a, "{a: 1, b: \"omg\"}", {a: 1, b: "omg"});
        });
      });

      d.describe("on typedefed struct, it inspects like anonymous ones, since I can't figure out how to get the type info off of it", function(d) {
        d.it("inspects empty structs", function(a) {
          var s0:TypeDefedStruct0 = {};
          inspectsTo(a, "{}", s0);

          var s1:TypeDefedStruct1 = {x: 1};
          inspectsTo(a, "{x: 1}", s1);

          var s2:TypeDefedStruct2 = {x: 1, y: "abc"};
          inspectsTo(a, "{x: 1, y: \"abc\"}", s2);
        });
      });

      d.describe('on functions', function(d) {
        d.it('returns a function looking thing with obvious "fuck if I know" indocators', function(a) {
          inspectsTo(a, 'function(??) { ?? }', function() {});
          inspectsTo(a, 'function(??) { ?? }', function(a) return 1);
        });
      });

      d.describe('on Enum instances', function(d) {
        d.it('returns the literal that would construct them', function(a) {
          // I think this is what I ideally want (or maybe it needs to have DescribeInspect in there, too
          // but there doesn't appear to be any way to access it from within Haxe :(
          //
          // a.eq('toplevel.FixtureEnum.ZeroArgs', inspect(ZeroArgs));
          // a.eq('toplevel.FixtureEnum.OneArg("abc")', inspect(OneArg("abc")));
          // a.eq('toplevel.FixtureEnum.TwoArgs("abc", "defg")', inspect(TwoArgs("abc", "defg")));
          inspectsTo(a, 'ZeroArgs', ZeroArgs);
          inspectsTo(a, 'OneArg("abc")', OneArg("abc"));
          inspectsTo(a, 'TwoArgs("abc", "defg")', TwoArgs("abc", "defg"));
        });
      });

      d.describe("on unknown", function(d) {
        d.it('displays "Unknown(s)", where s is whatever Std.string returns', function(a) {
          inspectsTo(a, "Unknown(#abstract)", getUnknown());
        });
      });
    });
  }
}
