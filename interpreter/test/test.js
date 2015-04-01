var parse  = require("parse")
var assert = require("assert") // https://github.com/joyent/node/blob/9010dd26529cea60b7ee55ddae12688f81a09fcb/lib/assert.js

describe('Parse', ()=>{
  describe('expressions', ()=>{
    it('parses single expressions, tracking location information', (done)=>{
      parse('nil', (parsed) => {
        assert.equal('nil', parsed.type);
        assert.equal(0,     parsed.location.begin);
        assert.equal(3,     parsed.location.end);
        done()
      })
    })

    it('parses multiple expressions, tracking location information for each', (done) => {
      parse('9;4', (parsed) => {
        assert.equal('expressions', parsed.type)
        assert.equal(0,             parsed.location.begin)
        assert.equal(3,             parsed.location.end)
        assert.equal(2,             parsed.expressions.length)

        let exprs = parsed.expressions

        let first = exprs[0]
        assert.equal('integer', first.type)
        assert.equal(9,         first.value)
        assert.equal(0,         first.location.begin)
        assert.equal(1,         first.location.end)

        let second = exprs[1]
        assert.equal('integer', second.type)
        assert.equal(4,         second.value)
        assert.equal(2,         second.location.begin)
        assert.equal(3,         second.location.end)
        done()
      })
    })
  })

  describe('literals', function() {
    it('nil',   function(done) {
      parse('nil', (parsed) => {
        assert.equal('nil', parsed.type)
        assert.equal(0,     parsed.location.begin)
        assert.equal(3,     parsed.location.end)
        done()
      })
    })
    it('true',  function(done) {
      parse('true', (parsed) => {
        assert.equal('true', parsed.type)
        assert.equal(0,      parsed.location.begin)
        assert.equal(4,      parsed.location.end)
        done()
      })
    })
    it('false', function(done) {
      parse('false', (parsed) => {
        assert.equal('false', parsed.type)
        assert.equal(0,       parsed.location.begin)
        assert.equal(5,       parsed.location.end)
        done()
      })
    })
    it('self',  function(done) {
      parse('self', (parsed) => {
        assert.equal('self', parsed.type)
        assert.equal(0,      parsed.location.begin)
        assert.equal(4,      parsed.location.end)
        done()
      })
    })
    it('positive integers', function(done) {
      parse('1', (parsed) => {
        assert.equal('integer', parsed.type)
        assert.equal(1,         parsed.value)
        assert.equal(0,         parsed.location.begin)
        assert.equal(1,         parsed.location.end)
        done()
      })
    })
    it('negative integers', function(done) {
      parse('-123', (parsed) => {
        assert.equal('integer', parsed.type)
        assert.equal(-123,      parsed.value)
        assert.equal(0,         parsed.location.begin)
        assert.equal(4,         parsed.location.end)
        done()
      })
    })
    it('negative float', function(done) {
      parse('-12.34', (parsed) => {
        assert.equal('float', parsed.type)
        assert.equal(-12.34,  parsed.value)
        assert.equal(0,       parsed.location.begin)
        assert.equal(6,       parsed.location.end)
        done()
      })
    })
    it('positive float', function(done) {
      parse('1.0', (parsed) => {
        assert.equal('float', parsed.type)
        assert.equal(1.0,     parsed.value)
        assert.equal(0,       parsed.location.begin)
        assert.equal(3,       parsed.location.end)
        done()
      })
    })
    it('string', function(done) {
      parse('"abc"', (parsed) => {
        assert.equal('string', parsed.type)
        assert.equal("abc",    parsed.value)
        assert.equal(0,        parsed.location.begin)
        assert.equal(5,        parsed.location.end)
        done()
      })
    })
  })
})

/*
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
*/
