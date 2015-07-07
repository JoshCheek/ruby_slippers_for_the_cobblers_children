const stateMachines = {
  step: require('./state_machines')
}

const VM = function(world) {
  this.world = world
}

VM.prototype.nextExpression = function() {
  const statestack  = this.world.statestack
  while(!stateMachines.step(this, statestack)) { }
  return this.currentExpression()
}

VM.prototype.currentBinding = function() {
  return this.world.callstack[this.world.callstack.length-1]
}

VM.prototype.currentExpression = function() {
  const id = this.currentBinding().returnValue
  return this.lookup(id)
}

VM.prototype.setCurrentExpression = function(value) {
  this.currentBinding().returnValue = value.objectId
}

VM.prototype.lookup = function(id) {
  return this.world.allObjects[id]
}

const buildWorld = require('./build_world')
VM.bootstrap = function(ast) {
  return new VM(buildWorld(ast))
}

module.exports = VM
