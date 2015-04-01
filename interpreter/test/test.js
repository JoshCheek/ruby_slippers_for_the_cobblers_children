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

  describe('variables', () => {
    context('Constant', () => {
      it('with no namespace', (done) => {
        parse("A", (parsed) => {
          assert.equal('constant', parsed.type)
          assert.equal("A",        parsed.name)
          assert.equal(null,       parsed.namespace)
          assert.equal(0,          parsed.location.begin)
          assert.equal(1,          parsed.location.end)
          done()
        })
      })

      it('with a namespace', (done) => {
        parse("A::B", (parsed) => {
          assert.equal('constant', parsed.type)
          assert.equal("B",        parsed.name)
          assert.equal(0,          parsed.location.begin)
          assert.equal(4,          parsed.location.end)

          var aClass = parsed.namespace
          assert.equal('constant', aClass.type)
          assert.equal("A",        aClass.name)
          assert.equal(0,          aClass.location.begin)
          assert.equal(1,          aClass.location.end)
          done()
        })
      })
    })

    it('setting and getting local vars', (done) => {
      parse("a = 1; a", (parsed) => {
        assert.equal('expressions', parsed.type)
        assert.equal(2,             parsed.expressions.length)

        // setter
        let setlvar = parsed.expressions[0]
        assert.equal('set_local_variable', setlvar.type)
        assert.equal('a',                  setlvar.name)
        assert.equal(0,                    setlvar.location.begin)
        assert.equal(5,                    setlvar.location.end)

        assert.equal('integer', setlvar.value.type)
        assert.equal(1,         setlvar.value.value)
        assert.equal(4,         setlvar.value.location.begin)
        assert.equal(5,         setlvar.value.location.end)

        // getter
        let getlvar = parsed.expressions[1]
        assert.equal('get_local_variable', getlvar.type)
        assert.equal('a',                  getlvar.name)
        assert.equal(7,                    getlvar.location.begin)
        assert.equal(8,                    getlvar.location.end)
        done()
      })
    })

    it('setting and getting instance vars', (done) => {
      parse("@a = 1; @a", (parsed) => {
        assert.equal(2, parsed.expressions.length)

        // setter
        let setivar = parsed.expressions[0]
        assert.equal('set_instance_variable', setivar.type)
        assert.equal('@a',                    setivar.name)
        assert.equal(0,                       setivar.location.begin)
        assert.equal(6,                       setivar.location.end)

        assert.equal(1,                       setivar.value.value)
        assert.equal(5,                       setivar.value.location.begin)
        assert.equal(6,                       setivar.value.location.end)

        // getter
        let getivar = parsed.expressions[1]
        assert.equal('get_instance_variable', getivar.type)
        assert.equal('@a',                    getivar.name)
        assert.equal(8,                       getivar.location.begin)
        assert.equal(10,                      getivar.location.end)
        done()
      })
    })
  })

  describe('sending messages', function() {
    it('parses the target, message, and arguments', function(done) {
      parse("true.something(false)", (parsed) => {
        assert.equal('send', parsed.type)
        assert.equal(0,  parsed.location.begin)
        assert.equal(21, parsed.location.end)

        // target
        let target = parsed.target
        assert.equal('true', target.type)
        assert.equal(0,      target.location.begin)
        assert.equal(4,      target.location.end)

        // message
        assert.equal("something", parsed.message)

        // arguments
        assert.equal(1, parsed.args.length)
        let arg = parsed.args[0]
        assert.equal('false', arg.type)
        assert.equal(15,      arg.location.begin)
        assert.equal(20,      arg.location.end)
        done()
      })
    })
  })
})


/*

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
