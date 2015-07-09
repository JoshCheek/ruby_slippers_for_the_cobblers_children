const buildWorld = require('./build_world')

const VM = function(world) {
  this.world = world
}

VM.bootstrap = function(ast) {
  return new VM(buildWorld(ast))
}

VM.prototype.nextExpression = function() {
  return this.world.mainMachine.nextExpression()
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

module.exports = VM
