#!/usr/bin/env node

// $ npm install acorn
var acorn   = require("acorn"),
    code    = "describe('Parse', function() {\n" +
              "  it('parses single expressions, tracking location information', function(done) {\n" +
              "    parsed <- parse('nil')\n" +
              "    assert.equal('nil', parsed.type);\n" +
              "    assert.equal(0,     parsed.location.begin);\n" +
              "    assert.equal(3,     parsed.location.end);\n" +
              "    done()\n" +
              "  })\n" +
              "})\n",
    options = {},
    parsed  = acorn.parse(code, options)

console.log(parsed)
console.log(parsed.body)
