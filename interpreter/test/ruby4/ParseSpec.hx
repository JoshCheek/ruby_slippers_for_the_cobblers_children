package ruby4;
import ruby4.Parse;
import ruby4.ast.Ast;
using Inspect;

class ParseSpec {
  public static function parse(rubyCode:String) {
    return Parse.fromString(rubyCode);
  }

  public static function describe(d:spaceCadet.Description) {
    var parsed:Ast;
    d.before(function(a) parsed = null);

    d.describe('Parsing', function(d) {

      d.describe('inspect', function(d) {
        d.specify('is hopefully valid json, with the class as a "type" field', function(a) {
          var inspected = parse("nil").inspect();
          a.eq('{', inspected.charAt(0));
          a.eq('}', inspected.charAt(inspected.length-1));
          a.isTrue(~/"type": "ruby4.ast.NilAst"/.match(inspected));
        });
      });

      d.describe('expressions', function(d) {
        d.it('parses single expressions, tracking location information', function(a) {
          parsed = parse('nil');
          a.isTrue(parsed.isNil);
          a.eq(0, parsed.begin_loc);
          a.eq(3, parsed.end_loc);
        });
        d.it('parses multiple expressions, tracking location information for each', function(a) {
          parsed = parse('9;4');

          a.isTrue(parsed.isExprs);
          a.eq(0, parsed.begin_loc);
          a.eq(3, parsed.end_loc);

          var exprs = parsed.toExprs();
          a.eq(2, exprs.length);

          var first = exprs.get(0).toInteger();
          a.eq(9, first.value);
          a.eq(0, first.begin_loc);
          a.eq(1, first.end_loc);

          var second = exprs.get(1).toInteger();
          a.eq(4, second.value);
          a.eq(2, second.begin_loc);
          a.eq(3, second.end_loc);
        });
      });

      d.describe('literals', function(d) {
        d.example('nil',   function(a) {
          parsed = parse('nil');
          a.isTrue(parsed.isNil);
          parsed.toNil();
          a.eq(0, parsed.begin_loc);
          a.eq(3, parsed.end_loc);
        });
        d.example('true',  function(a) {
          parsed = parse('true');
          a.isTrue(parsed.isTrue);
          parsed.toTrue();
          a.eq(0, parsed.begin_loc);
          a.eq(4, parsed.end_loc);
        });
        d.example('false', function(a) {
          parsed = parse('false');
          a.isTrue(parsed.isFalse);
          parsed.toFalse();
          a.eq(0, parsed.begin_loc);
          a.eq(5, parsed.end_loc);
        });
        d.example('self',  function(a) {
          parsed = parse('self');
          a.isTrue(parsed.isSelf);
          parsed.toSelf();
          a.eq(0, parsed.begin_loc);
          a.eq(4, parsed.end_loc);
        });
        d.example('integers', function(a) {
          parsed = parse('1');
          a.isTrue(parsed.isInteger);
          a.eq(1, parsed.toInteger().value);
          a.eq(0, parsed.begin_loc);
          a.eq(1, parsed.end_loc);

          parsed = parse('-123');
          a.isTrue(parsed.isInteger);
          a.eq(-123, parsed.toInteger().value);
          a.eq(0, parsed.begin_loc);
          a.eq(4, parsed.end_loc);
        });
        d.example('float', function(a) {
          parsed = parse('-12.34');
          a.isTrue(parsed.isFloat);
          a.eq(-12.34, parsed.toFloat().value);
          a.eq(0, parsed.begin_loc);
          a.eq(6, parsed.end_loc);

          parsed = parse('1.0');
          a.isTrue(parsed.isFloat);
          a.eq(1.0, parsed.toFloat().value);
          a.eq(0, parsed.begin_loc);
          a.eq(3, parsed.end_loc);
        });
        d.example('string', function(a) {
          parsed = parse('"abc"');
          a.isTrue(parsed.isString);
          a.eq("abc", parsed.toString().value);
          a.eq(0, parsed.begin_loc);
          a.eq(5, parsed.end_loc);
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
            a.eq(0, parsed.begin_loc);
            a.eq(1, parsed.end_loc);
          });
          d.example('with a namespace', function(a) {
            parsed = parse("A::B");
            var const = parsed.toConst();
            a.eq("B", const.name);
            a.eq(0, parsed.begin_loc);
            a.eq(4, parsed.end_loc);

            var aClass = const.ns.toConst();
            a.eq("A", aClass.name);
            a.eq(0, aClass.begin_loc);
            a.eq(1, aClass.end_loc);

            a.eq(true, aClass.ns.isDefault);
            a.eq(-1, aClass.ns.begin_loc);
            a.eq(-1, aClass.ns.end_loc);
          });
        });
        d.example('setting and getting local vars', function(a) {
          var exprs = parse("a = 1; a").toExprs();
          a.eq(2, exprs.length);

          // setter
          a.isTrue(exprs.get(0).isSetLvar);
          var setlvar = exprs.get(0).toSetLvar();
          a.eq('a', setlvar.name);
          a.eq(0, setlvar.begin_loc);
          a.eq(5, setlvar.end_loc);

          a.eq(1, setlvar.value.toInteger().value);
          a.eq(4, setlvar.value.begin_loc);
          a.eq(5, setlvar.value.end_loc);

          // getter
          var getlvar = exprs.get(1).toGetLvar();
          a.isTrue(getlvar.isGetLvar);
          a.eq('a', getlvar.name);
          a.eq(7, getlvar.begin_loc);
          a.eq(8, getlvar.end_loc);
        });
        d.example('setting and getting instance vars', function(a) {
          var exprs = parse("@a = 1; @a").toExprs();
          a.eq(2, exprs.length);

          // setter
          a.isTrue(exprs.get(0).isSetIvar);
          var setivar = exprs.get(0).toSetIvar();
          a.eq('@a', setivar.name);
          a.eq(0, setivar.begin_loc);
          a.eq(6, setivar.end_loc);

          a.eq(1, setivar.value.toInteger().value);
          a.eq(5, setivar.value.begin_loc);
          a.eq(6, setivar.value.end_loc);

          // getter
          var getivar = exprs.get(1).toGetIvar();
          a.isTrue(getivar.isGetIvar);
          a.eq('@a', getivar.name);
          a.eq(8,  getivar.begin_loc);
          a.eq(10, getivar.end_loc);
        });
      });

      d.describe('sending messages', function(d) {
        d.it('parses the target, message, and arguments', function(a) {
          parsed = parse("true.something(false)");
          a.isTrue(parsed.isSend);
          a.eq(0,  parsed.begin_loc);
          a.eq(21, parsed.end_loc);
          var send = parsed.toSend();

          // target
          var target = send.target.toTrue();
          a.eq(0, target.begin_loc);
          a.eq(4, target.end_loc);

          // message
          a.eq("something", send.message);

          // arguments
          a.eq(1, send.arguments.length);
          var arg = send.arguments[0].toFalse();
          a.eq(15, arg.begin_loc);
          a.eq(20, arg.end_loc);
        });
      });

      d.describe('class definitions', function(d) {
        d.it('parses the namespace, name, superclas, and body', function(a) {
          parsed = parse("class A::B < C; 1; end");
          a.isTrue(parsed.isOpenClass);
          var klass = parsed.toOpenClass();
          a.eq(0,  klass.begin_loc);
          a.eq(22, klass.end_loc);

          // namespace
          a.eq('B', klass.ns.toConst().name);
          a.eq(6,   klass.ns.begin_loc);
          a.eq(10,  klass.ns.end_loc);
          a.eq('A', klass.ns.toConst().ns.toConst().name);

          // superclass
          a.eq('C', klass.superclass.toConst().name);
          a.eq(13,  klass.superclass.begin_loc);
          a.eq(14,  klass.superclass.end_loc);

          // body
          a.eq(1,   klass.body.toInteger().value);
          a.eq(16,  klass.body.begin_loc);
          a.eq(17,  klass.body.end_loc);
        });

        d.it('parses defaults -- no namespace, superclass, or body', function(a) {
          parsed = parse("class A; end");
          a.isTrue(parsed.isOpenClass);
          var klass = parsed.toOpenClass();
          a.eq('A', klass.ns.toConst().name);
          a.isTrue(klass.ns.toConst().ns.isDefault);
          a.isTrue(klass.superclass.isDefault);
          a.isTrue(klass.body.isDefault);
        });
      });

      // d.describe('module definitions', function(d) {
      // });

      d.describe('method definitions', function(d) {
        d.example('with no parameters or body', function(a) {
          parsed = parse("def bland_method; end");
          a.isTrue(parsed.isDef);
          a.eq(0,  parsed.begin_loc);
          a.eq(21, parsed.end_loc);

          var def = parsed.toDef();
          a.eq("bland_method", def.name); // name
          a.eq(0, def.parameters.length); // parameters
          a.isTrue(def.body.isDefault);   // body
          a.eq(-1, def.body.begin_loc);
          a.eq(-1, def.body.end_loc);
        });
        d.example('with a body', function(a) {
          var def = parse("def hasbody; true; end").toDef();
          a.isTrue(def.body.isTrue);
          a.eq(13, def.body.begin_loc);
          a.eq(17, def.body.end_loc);
        });
        d.example('with required and rest args', function(a) {
          var def = parse("def hasargs(req, *rst); end").toDef();
          a.eq(2, def.parameters.length);

          var req = def.parameters[0];
          a.eq(req.type, Required);
          a.eq('req', req.name);
          a.eq(12, req.begin_loc);
          a.eq(15, req.end_loc);

          var rest = def.parameters[1];
          a.eq(rest.type, Rest);
          a.eq('rst', rest.name);
          a.eq(17, rest.begin_loc);
          a.eq(21, rest.end_loc);
        });
      });
    });
  }
}
