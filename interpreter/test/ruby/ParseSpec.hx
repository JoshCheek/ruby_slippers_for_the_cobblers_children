package ruby;
using Inspect;

class ParseSpec {
  public static function parse(rubyCode:String) {
    return ruby.Parse.fromString(rubyCode);
  }

  // public static function exprs(exprs) {
  //   return Exprs(Start(exprs));
  // }

  public static function describe(d:spaceCadet.Description) {
    var parsed:ruby.Parse.Ast;
    d.before(function(a) parsed = null);

    d.describe('Parsing', function(d) {

      d.describe('expressions', function(d) {
        d.it('parses single expressions', function(a) {
          a.isTrue(parse('nil').isNil);
        });
        d.it('parses multiple expressions', function(a) {
          parsed = parse('9;4');
          a.isTrue(parsed.isExprs);
          var exprs = parsed.toExprs();
          a.eq(2, exprs.length);
          a.eq(9, exprs.get(0).toInteger().value);
          a.eq(4, exprs.get(1).toInteger().value);
        });
      });

      d.describe('literals', function(d) {
        d.example('nil',   function(a) {
          parsed = parse('nil');
          a.isTrue(parsed.isNil);
          parsed.toNil();
        });
        d.example('true',  function(a) {
          parsed = parse('true');
          a.isTrue(parsed.isTrue);
          parsed.toTrue();
        });
        d.example('false', function(a) {
          parsed = parse('false');
          a.isTrue(parsed.isFalse);
          parsed.toFalse();
        });
        d.example('self',  function(a) {
          parsed = parse('self');
          a.isTrue(parsed.isSelf);
          parsed.toSelf();
        });
        d.example('integers', function(a) {
          parsed = parse('1');
          a.isTrue(parsed.isInteger);
          a.eq(1, parsed.toInteger().value);

          parsed = parse('-123');
          a.isTrue(parsed.isInteger);
          a.eq(-123, parsed.toInteger().value);
        });
        d.example('float', function(a) {
          parsed = parse('-12.34');
          a.isTrue(parsed.isFloat);
          a.eq(-12.34, parsed.toFloat().value);

          parsed = parse('1.0');
          a.isTrue(parsed.isFloat);
          a.eq(1.0, parsed.toFloat().value);
        });
        d.example('string', function(a) {
          parsed = parse('"abc"');
          a.isTrue(parsed.isString);
          a.eq("abc", parsed.toString().value);
        });
      });


      d.describe('variables', function(d) {
        d.context('Constant', function(a) {
          d.example('with no namespace', function(a) {
            parsed = parse("A");
            a.isTrue(parsed.isConst);
            var const = parsed.toConst();
            a.eq("A", const.name);
            a.eq(true, const.ns.isDefault);
          });
          d.example('with a namespace', function(a) {
            parsed = parse("A::B");
            var const = parsed.toConst();
            a.eq("B", const.name);
            a.eq("A", const.ns.toConst().name);
            a.eq(true, const.ns.toConst().ns.isDefault);
          });
        });
        // d.example('setting and getting local vars', function(a) {
        //   parsed = parse("a = 1; a").toExprs();
        //   a.
        //     exprs( [SetLvar(FindRhs("a", Integer(1))),
        //             GetLvar(Name("a"))]));
        // });
        // d.example('setting and getting instance vars', function(a) {
        //   parses(a, "@a = 1; @a",
        //     exprs( [SetIvar(FindRhs("@a", Integer(1))),
        //             GetIvar(Name("@a"))]));
        // });
      });

      // d.describe('sending messages', function(d) {
      //   d.it('parses the target, message, and arguments', function(a) {
      //     parses(a, "true.something(false)", Send(Start(True({begin:0, end:4}),
      //                                                   "something",
      //                                                   [False])));
      //   });
      // });

      // d.describe('class definitions', function(d) {
      //   d.it('parses the namespace, name, superclas, and body', function(a) {
      //     parses(a, "class A::B < C
      //                  1
      //                end",
      //        OpenClass(GetNs(
      //          Const(GetNs(  Const(GetNs(Default, "A")), "B")),
      //          Const(GetNs(Default, "C")),
      //          Integer(1)
      //        )));
      //   });

      //   d.it('parses defaults there is no namespace, superclass, or body', function(a) {
      //     parses(a, "class A; end", OpenClass(GetNs(
      //                                 Const(GetNs(Default, "A")),
      //                                 Default,
      //                                 Default
      //                               )));
      //   });

      //   d.it('parses nested declarations', function(a) {
      //     parses(a, "class A; class B; end; end",
      //       OpenClass(GetNs(
      //         Const(GetNs(Default, "A")),
      //         Default,
      //         OpenClass(GetNs(
      //           Const(GetNs(Default, "B")),
      //           Default,
      //           Default
      //         ))
      //       ))
      //     );
      //   });
      // });

      // d.describe('module definitions', function(d) {
      // });

      // d.describe('method definitions', function(d) {
      //   d.example('with no args or body', function(a) {
      //     parses(a, "def bland_method; end", Def(Start("bland_method", [], Default)));
      //   });
      //   d.example('with a body', function(a) {
      //     parses(a, "def hasbody; true; end", Def(Start("hasbody", [], True({begin:13, end:17}))));
      //   });
      //   d.example('with required and rest args', function(a) {
      //     parses(a, "def hasargs(req, *rst); end",
      //         Def(Start("hasargs",
      //           [Required("req"), Rest("rst")],
      //           Default
      //         )));
      //   });
      // });
    });
  }
}
