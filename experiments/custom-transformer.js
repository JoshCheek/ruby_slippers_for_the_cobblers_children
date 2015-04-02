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
let rawTransformer = (node) => {
  types.ensureBlock(node)

  node._aliasFunction = "omg"
  node.expression     = false
  node.type           = "FunctionExpression"
  return node
}

// > console.log(babel.types.isArrowFunctionExpression.toString())
// function (node, opts) {
//   return t.is(type, node, opts, skipAliasCheck);
// }
//
// experimentally, opts seems to always be undefined
rawTransformer.check = (node, opts) => {
  console.log(`${inspect(node)}\n\n----------------------\n`)
  return false
}


// ==========  add it to babel ==========
// code to add it taken from
//   https://github.com/babel/babel/blob/cfff7aa6fb257cf39a85e7b06a5c49e8501ea32b/src/babel/transformation/index.js
// the key/value come from a giant list
//   https://github.com/babel/babel/blob/cfff7aa6fb257cf39a85e7b06a5c49e8501ea32b/src/babel/transformation/transformers/index.js
let key         = 'es6.omg',
    namespace   = key.split(".")[0];

if(!transform.namespaces[namespace])
  transform.namespaces[namespace] = []
transform.namespaces[namespace].push(key)
transform.transformerNamespaces[key] = namespace
transform.transformers[key]          = new Transformer(key, rawTransformer)


// ==========  transform some code  ==========
let code = 'a <- b()',            // this is what I'd ultimately like to transform
    opts = { modules: "common" }; // seems to determine output format (eg won't wrap in an anon fn)
console.log(babel.transform(code, opts))
