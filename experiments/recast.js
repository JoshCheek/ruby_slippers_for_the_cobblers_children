var recast  = require("recast"),
    code    = "describe('Parse', function() {\n" +
              "  it('parses single expressions, tracking location information', function(done) {\n" +
              "    parsed <- parse('nil')\n" +
              "    assert.equal('nil', parsed.type);\n" +
              "    assert.equal(0,     parsed.location.begin);\n" +
              "    assert.equal(3,     parsed.location.end);\n" +
              "    done()\n" +
              "  })\n" +
              "})\n",
    ast     = recast.parse(code)

// Parse the code using an interface similar to require("esprima").parse.
console.log(ast)


// // Grab a reference to the function declaration we just parsed.
// var add = ast.program.body[0];
//
// // Make sure it's a FunctionDeclaration (optional).
// var n = recast.types.namedTypes;
// n.FunctionDeclaration.assert(add);
//
// // If you choose to use recast.builders to construct new AST nodes, all builder
// // arguments will be dynamically type-checked against the Mozilla Parser API.
// var b = recast.types.builders;
//
// // This kind of manipulation should seem familiar if you've used Esprima or the
// // Mozilla Parser API before.
// ast.program.body[0] = b.variableDeclaration("var", [
//     b.variableDeclarator(add.id, b.functionExpression(
//         null, // Anonymize the function expression.
//         add.params,
//         add.body
//     ))
// ]);
//
// // Just for fun, because addition is commutative:
// add.params.push(add.params.shift());

var output = recast.print(ast).code;
// console.log(output)
