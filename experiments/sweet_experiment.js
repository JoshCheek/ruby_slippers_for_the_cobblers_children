// macro import {
//   rule { { $import:alias_pair (,) ... } from $mod:lit ;... } => {
//     var __module = require($mod);
//     $(var $import$to = __module.$import$from;) ...
//   }
//   rule { $default:ident from $mod:lit ;... } => {
//     var $default = require($mod).default;
//   }
// }
//
// import { a, b as c, d } from 'foo'
// // expands to:
// // var __module = require('foo');
// // var a = __module.a;
// // var c = __module.b;
// // var d = __module.d;

macro (<-) {
  case infix { $param:ident | $name $call:expr } => {
    return #{$call($param)}
  }
}


// syntax from the test
describe('Parse', ()=>{
  it('parses single expressions, tracking location information', (done)=>{
    parsed <- parse('nil')
    assert.equal('nil', parsed.type);
    assert.equal(0,     parsed.location.begin);
    assert.equal(3,     parsed.location.end);
    done()
  })
})

// out should be:
// describe('Parse', ()=>{
//   it('parses single expressions, tracking location information', (done)=>{
//     parse('nil', (parsed) => {
//       assert.equal('nil', parsed.type);
//       assert.equal(0,     parsed.location.begin);
//       assert.equal(3,     parsed.location.end);
//       done()
//     })
//   })
// })
