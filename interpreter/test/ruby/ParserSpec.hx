package ruby;
import ruby.ds.Interpreter;
using Lambda;
using Inspect;

// god I fucking hate ADTs
class ParserSpec {
  public static function parses(a:spaceCadet.Asserter, rubyCode:String, expected:ExecutionState, ?c:haxe.PosInfos) {
    var actual = ruby.ParseRuby.fromCode(rubyCode);
    a.eq(expected.inspect(), actual.inspect(), c);
  }

  public static function exprs(exprs) {
    return Exprs(Start(exprs));
  }

  public static function describe(d:spaceCadet.Description) {
    d.describe('Parsing', function(d) {
      d.describe('literals', function(d) {
        d.example('nil',   function(a) parses(a, 'nil',   Nil({begin: 0, end: 3})));
        d.example('true',  function(a) parses(a, 'true',  True));
        d.example('false', function(a) parses(a, 'false', False));
        d.example('self',  function(a) parses(a, 'self',  Self));
        d.example('integers', function(a) {
          parses(a, "1",    Integer(1));
          parses(a, "-123", Integer(-123));
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
        d.context('Constant', function(a) {
          d.example('with no namespace', function(a) {
            parses(a, "A", Const(GetNs(Default, "A")));
          });
          d.example('with a namespace', function(a) {
            parses(a, "A::B", Const(GetNs(Const(GetNs(Default, "A")), "B")));
          });
        });
        d.it('setting and getting local vars', function(a) {
          parses(a, "a = 1; a",
            exprs( [SetLvar(FindRhs("a", Integer(1))),
                    GetLvar(Name("a"))]));
        });
        d.it('setting and getting instance vars', function(a) {
          parses(a, "@a = 1; @a",
            exprs( [SetIvar(FindRhs("@a", Integer(1))),
                    GetIvar(Name("@a"))]));
        });
      });

      d.describe('sending messages', function(d) {
        d.it('parses the target, message, and arguments', function(a) {
          parses(a, "true.something(false)", Send(Start(True, "something", [False])));
        });
      });

      d.describe('class definitions', function(d) {
        d.it('parses the namespace, name, superclas, and body', function(a) {
          parses(a, "class A::B < C
                       1
                     end",
             OpenClass(GetNs(
               Const(GetNs(  Const(GetNs(Default, "A")), "B")),
               Const(GetNs(Default, "C")),
               Integer(1)
             )));
        });

        d.it('parses defaults there is no namespace, superclass, or body', function(a) {
          parses(a, "class A; end", OpenClass(GetNs(
                                      Const(GetNs(Default, "A")),
                                      Default,
                                      Default
                                    )));
        });

        d.it('parses nested declarations', function(a) {
          parses(a, "class A; class B; end; end",
            OpenClass(GetNs(
              Const(GetNs(Default, "A")),
              Default,
              OpenClass(GetNs(
                Const(GetNs(Default, "B")),
                Default,
                Default
              ))
            ))
          );
        });
      });

      d.describe('module definitions', function(d) {
      });

      d.describe('method definitions', function(d) {
        d.example('with no args or body', function(a) {
          parses(a, "def bland_method; end", Def(Start("bland_method", [], Default)));
        });
        d.example('with a body', function(a) {
          parses(a, "def hasbody; true; end", Def(Start("hasbody", [], True)));
        });
        d.example('with required and rest args', function(a) {
          parses(a, "def hasargs(req, *rst); end",
              Def(Start("hasargs",
                [Required("req"), Rest("rst")],
                Default
              )));
        });
      });
    });
  }
}
