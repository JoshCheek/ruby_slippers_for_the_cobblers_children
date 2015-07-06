var VM = function(world) {
  this.world = world
}

VM.prototype.currentBinding = function() {
  return this.world.callstack[this.world.callstack.length-1]
}

VM.prototype.currentExpression = function() {
  return this.world.currentBinding.returnValue
}

VM.prototype.nextExpression = function() {
  let rTrue = this.rTrue
  let tmpBullshit = function(ast) {
    switch(ast.type) {
      case "true": return rTrue;
      default: throw(`Unexpected ast: ${ast}`)
    }
  }

  return tmpBullshit(this.world.ast)
}


VM.bootstrap = function(ast) {
  // helpers
  let instantiate = function(klass) {
    return { class: klass, instance_variables: {} }
  }

  // Class and Object
  let rClass = {
    instance_variables: {},
  }
  rClass.class = rClass

  let rObject = {
    instance_variables: {},
    class:              rClass,
  }

  // true
  let rTrueClass = instantiate(rClass)
  let rTrue      = instantiate(rTrueClass)

  // callstack
  let main = instantiate(rObject)
  let toplevelBinding = {
    localVariables: {},
    self:           main,
    returnValue:    rTrue
  }
  let callstack = [toplevelBinding]

  // put it all together
  let world = {
    ast:       ast,
    rTrue:     rTrue,
    callstack: callstack,
  }

  return new VM(world)
}

module.exports = VM
