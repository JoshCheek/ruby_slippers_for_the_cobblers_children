#!/usr/bin/env babel-node

// install deps with:
//   npm install babel  // seem to have to do this all the fkn time -.-
// possibly relevant:
//   https://developer.mozilla.org/en-US/docs/Mozilla/Projects/SpiderMonkey/Parser_API

// get refs to the relevant babel objects
let babel       = require('babel'),
    transform   = babel.transform,
    Transformer = babel.transform.transformers['es6.arrowFunctions'].constructor,
    types       = babel.types,
    inspect     = require('util').inspect;


// ==========  build the raw transformer  ==========
// example of a raw transformer
//   > babel.transform.transformers['es6.arrowFunctions']
//   { manipulateOptions: undefined,
//     check: [Function],
//     post: undefined,
//     pre: undefined,
//     experimental: false,
//     playground: false,
//     secondPass: false,
//     optional: false,
//     __esModule: true,
//     handlers:
//      { ArrowFunctionExpression:
//         { enter: [Function: ArrowFunctionExpression],
//           exit: [Function] },
//        __esModule: true },
//     opts: {},
//     key: 'es6.arrowFunctions' }

// used arrow-functions as a reference
// https://github.com/babel/babel/blob/cfff7aa6fb257cf39a85e7b06a5c49e8501ea32b/src/babel/transformation/transformers/es6/arrow-functions.js
var rawTransformer = {
  Omg: function Omg(node) {
    throw new Error("MADE IT INTO THE TRANSFORMER!!!");
    // console.log(`TRANSFORM CALLED WITH ${inspect(node)}`)
    types.ensureBlock(node)

    node._aliasFunction = "omg"
    node.expression     = false
    node.type           = "FunctionExpression"
    return node
  }
}

// check: isOmg,
rawTransformer.check = function(node, opts) {
  // if(node.type === 'File')
  //   console.log(inspect(node.tokens))
  console.log(inspect(node))
  console.log('-------------------------')
  return false;
}

// ==========  add it to babel ==========
// code to add it taken from
//   https://github.com/babel/babel/blob/cfff7aa6fb257cf39a85e7b06a5c49e8501ea32b/src/babel/transformation/index.js
// the key/value come from a giant list
//   https://github.com/babel/babel/blob/cfff7aa6fb257cf39a85e7b06a5c49e8501ea32b/src/babel/transformation/transformers/index.js
let key       = 'es6.omg',
    namespace = key.split(".")[0];

if(!transform.namespaces[namespace]) transform.namespaces[namespace] = []
transform.namespaces[namespace].push(key)
transform.transformerNamespaces[key] = namespace
transform.transformers[key]          = new Transformer(key, rawTransformer)

console.log(transform.transformers[key])
console.log(transform.transformers['es6.arrowFunctions'])


// ==========  idk  ==========
// https://github.com/babel/babel/blob/01a2aa7dd188f9a6701cbe743c87a36043f1c2a9/src/babel/types/index.js#L14
types.isOmg = function isOmg(node, opts) {
  throw new Error("MADE IT INTO IS OMG");
  return types.is('Omg', node, opts, false)
}
types.assertOmg = function(node, opts) {
  if(opts === undefined) opts = {}
  if (!types.is(node, opts))
    throw new Error(`Expected type "Omg" with option ${JSON.stringify(opts)}`)
}

  // // cb <- invoke_something()
  // if(node.type !== 'ExpressionStatement'            ) return false

  // let expr = node.expression
  // if(expr.type                !== 'BinaryExpression') return false
  // if(expr.operator            !== '<'               ) return false
  // if(expr.left.type           !== 'Identifier'      ) return false
  // if(expr.right.type          !== 'UnaryExpression' ) return false
  // if(expr.right.operator      !== '-'               ) return false
  // if(expr.right.argument.type !== 'CallExpression'  ) return false

  // console.log(`${inspect(node)}\n\n----------------------\n`)
  // return true
// }


// Don't really understand what these do, come in inverted for some reason
// the values come from acorn, as far as I can tell
// they seem to be property names on the acorn nodes
//
// currently used values:
// $ ruby -r pp -r yaml -e 'pp YAML.load(File.read "/Users/josh/code/ruby_slippers_for_the_cobblers_children/experiments/node_modules/babel/lib/babel/types/visitor-keys.json").values.flatten.uniq.sort'
// > alternate argument arguments attributes block blocks body callee cases children closingElement consequent
// > declaration declarations defaults discriminant elementType elements expression expressions extends filter
// > finalizer guardedHandlers handler handlers id implements init key label left name namespace object
// > openingElement param params program properties property qualification quasi quasis rest returnType
// > right source specifiers superClass superTypeParameters tag test typeAnnotation typeParameters types update value
//
// For a better breakdown, see babel_nodes.rb
//
// https://github.com/babel/babel/blob/01a2aa7dd188f9a6701cbe743c87a36043f1c2a9/src/babel/types/index.js#L86
// visitor key:  "ArrowFunctionExpression": ["params", "defaults", "rest", "body", "returnType"],
// builder key:  "ArrowFunctionExpression": { "params": null, "body": null },
// alias   key:  "ArrowFunctionExpression": ["Scopable", "Function", "Expression"],
// let visitorKeys = ['name']
// let visitorKeys = ['name', 'operator', 'operator', 'call']
let visitorKeys = ['name', 'operator', 'operator']
// let visitorKeys = ['left', 'right']
types.VISITOR_KEYS['Omg'] = visitorKeys

var defs = {};
visitorKeys.forEach(function(key) { defs[key] = null })
types.BUILDER_KEYS['Omg'] = defs

types['omg'] = function () {
  var node   = {};
  node.start = null;
  node.type  = 'Omg';
  var i = 0;
  for (var key in keys) {
    var arg = arguments[i++];
    if (arg === undefined) arg = keys[key];
    node[key] = arg;
  }
  return node;
}


// ==========  transform some code  ==========
let code = 'a <- b',            // this is what I'd ultimately like to transform
// let code = '(a) <- b.c(); a',            // this is what I'd ultimately like to transform
    opts = { modules: "common" }; // seems to determine output format (eg won't wrap in an anon fn)
console.log(babel.transform(code, opts).ast.program.body)
