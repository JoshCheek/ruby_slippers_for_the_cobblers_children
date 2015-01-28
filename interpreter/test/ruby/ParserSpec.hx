package ruby;
import ruby.ds.Interpreter;
using Lambda;
using Inspect;

class ParserSpec {
  public static function parses(a:spaceCadet.Asserter, rubyCode:String, expected:ExecutionState, ?c:haxe.PosInfos) {
    var actual = ruby.ParseRuby.fromCode(rubyCode);
    a.eq(expected.inspect(), actual.inspect(), c);
  }

  public static function describe(d:spaceCadet.Description) {
    d.describe('literals', function(d) {
      d.example('special objects', function(a) {
        parses(a, "nil; true; false; self",
                  Exprs(Start([Nil, True, False, Self])));
      });
      d.example('integers', function(a) {
        parses(a,"1; -123",
                 Exprs(Start([Integer(1), Integer(-123)])));
      });
      d.example('float', function(a) {
        parses(a, "-12.34", Float(-12.34));
        // parses(a, "1.0", Float(1.0)); // FIXME: it renders `Float(1.0)` to string as `Float(1)`
      });
      d.example('string', function(a) {
        parses(a, "'abc'", String("abc"));
      });
    });

    d.describe('variables', function(d) {
      d.it('parses them :P', function(a) {
        parses(a, "
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
      });
    });

    d.describe('sending messages', function(d) {
      d.it('parses the target, message, and arguments', function(a) {
        parses(a, "true.something(false)", Send(Start(True, "something", [False])));
      });
    });

    d.describe('class and module definitions', function(d) {
      d.it('parses lots of stuff...', function(a) {
        parses(a, "
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
      });
    });

    d.describe('method definitions', function(d) {
      d.it('parses them', function(a) {
        parses(a, "
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
      });
    });
  }
}
