"use strict";


// TODO: type could be abstract, in which case this is probably wrong
const Machine = function(world, state) {
  this.world           = world
  this.state           = state
}

// execution
Machine.prototype.nextExpression = function() {
  do { this.step() } while(!this.foundExpression)
  return this.currentExpression()
}

Machine.prototype.step = function() {
  this.foundExpression = false

}

// helpers
Machine.prototype.currentBinding = function() {
  return this.world.callstack.last
}

Machine.prototype.currentExpression = function() {
  return this.currentBinding().returnValue
}


module.exports = Machine


// function handleStepResult(vm, statestack, state, resultState) {
//   switch(resultState.type) {
//     case "push":
//       state.name = resultState.returnState
//       statestack.push({name: resultState.pushThis, registers: {}})
//       return false
//     case "advance":
//       state.name = resultState.nextState
//       return false
//     case "pop":
//       statestack.pop()
//       return resultState.expressionComplete
//     case "noop":
//       return resultState.expressionComplete
//     default: throw(new Error(`Unexpected state action: ${resultState}`))
//   }
// }

