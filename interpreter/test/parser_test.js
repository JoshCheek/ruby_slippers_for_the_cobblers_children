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

  describe('class definitions', function() {
    it('parses the namespace, name, superclas, and body', function(done) {
      parse("class A::B < C; 1; end", (parsed) => {
        assert.equal(parsed.isOpenClass)
        assert.equal('class', parsed.type)
        assert.equal(0,       parsed.location.begin)
        assert.equal(22,      parsed.location.end)

        // namespace
        assert.equal('B', parsed.name_lookup.name)
        assert.equal(6,   parsed.name_lookup.location.begin)
        assert.equal(10,  parsed.name_lookup.location.end)
        assert.equal('A', parsed.name_lookup.namespace.name)

        // superclass
        assert.equal('C', parsed.superclass.name)
        assert.equal(13,  parsed.superclass.location.begin)
        assert.equal(14,  parsed.superclass.location.end)

        // body
        assert.equal(1,   parsed.body.value)
        assert.equal(16,  parsed.body.location.begin)
        assert.equal(17,  parsed.body.location.end)
        done()
      })
    })

    it('parses defaults -- no namespace, superclass, or body', function(done) {
      parse("class A; end", (parsed) => {
        assert.equal('class',    parsed.type)
        assert.equal('constant', parsed.name_lookup.type)
        assert.equal('A',        parsed.name_lookup.name)
        assert.equal(null,       parsed.name_lookup.namespace)
        assert.equal(null,       parsed.superclass)
        assert.equal(null,       parsed.body)
        done()
      })
    })
  })

  describe('module definitions', function() {
  });

  describe('method definitions', function() {
    it('with no parameters or body', function(done) {
      parse("def bland_method; end", (parsed) => {
        assert.equal('method_definition', parsed.type)
        assert.equal(0,                   parsed.location.begin)
        assert.equal(21,                  parsed.location.end)

        assert.equal("bland_method", parsed.name)        // name
        assert.equal(0,              parsed.args.length) // parameters
        assert.equal(null,           parsed.body)        // body
        done()
      })
    })

    it('with a body', function(done) {
      parse("def hasbody; true; end", (parsed) => {
        assert.equal('true', parsed.body.type)
        assert.equal(13,     parsed.body.location.begin)
        assert.equal(17,     parsed.body.location.end)
        done()
      })
    })

    it('with required and rest args', function(done) {
      parse("def hasargs(req, *rst); end", (parsed) => {
        assert.equal(2, parsed.args.length)

        let req = parsed.args[0]
        assert.equal('required_arg', req.type)
        assert.equal('req',          req.name)
        assert.equal(12,             req.location.begin)
        assert.equal(15,             req.location.end)

        let rest = parsed.args[1]
        assert.equal('rest_arg', rest.type)
        assert.equal('rst',      rest.name)
        assert.equal(17,         rest.location.begin)
        assert.equal(21,         rest.location.end)
        done()
      })
    })
  })
})
