var VM = function(world) {
  this.world = world
}

VM.prototype.nextExpression = function() {
  const statestack  = this.world.statestack
  while(!this.step(statestack)) { }
  return this.currentExpression()
}

VM.prototype.currentBinding = function() {
  return this.world.callstack[this.world.callstack.length-1]
}

VM.prototype.currentExpression = function() {
  const id = this.currentBinding().returnValue
  return this.lookup(id)
}

VM.prototype.lookup = function(id) {
  return this.world.allObjects[id]
}

VM.prototype.step = function(statestack) {
  const state       = statestack[statestack.length-1]
  const resultState = this.stepMain(state)
  return this.handleStepResult(statestack, state, resultState)
}

VM.prototype.handleStepResult = function(statestack, state, resultState) {
  switch(resultState.type) {
    case "push":
      state.name = resultState.returnState
      statestack.push({name: resultState.pushThis, registers: {}})
      return false
    case "advance":
      state.name = resultState.nextState
      return false
    case "pop":
      statestack.pop()
      return resultState.expressionComplete
    case "noop":
      return resultState.expressionComplete
    default: throw(new Error(`Unexpected state action: ${resultState}`))
  }
}

VM.prototype.stepMain = function(state) {
  const actions    = this.step.actions
  switch(state.name) {
    case "start":
      state.substateStack = [this.astMachine(this.world.ast)]
      return actions.advance("running")

    case "running":
      const substack    = state.substateStack
      if(substack.length == 0)
        return actions.advance("finished")
      const state           = substack[substack.length-1]
      const expressionFound = this.handleStepResult(substack, state, this.stepRunning(state))
      return actions.noop(expressionFound)

    case "finished":
      this.currentBinding().returnValue = this.world.rNil.objectId
      return actions.noop(true)

    default: throw(new Error(`Unexpected state: ${JSON.stringify(state)}`))
  }
}

VM.prototype.step.actions = {
  push: function(pushStateName, returnStateName) {
    return {type: "push", pushThis: pushStateName, returnState: returnStateName}
  },
  advance: function(nextState) {
    return {type: "advance", nextState: nextState}
  },
  pop: function(expressionComplete) {
    return {type: "pop", expressionComplete: expressionComplete}
  },
  noop: function(expressionComplete) {
    return {type: "noop", expressionComplete: expressionComplete}
  },
}

VM.prototype.astMachine = function(ast) {
  const Type    = ast.type[0].toUpperCase() + ast.type.slice(1, ast.type.length)
  const state   = {
    name:      `eval${Type}`,
    ast:       ast,
    registers: {},
  }

  switch(ast.type) {
    case "true": return state
    default: throw(new Error(`Unexpected ast: ${ast.type}`))
  }
}

VM.prototype.stepRunning = function(state) {
  const actions = this.step.actions
  switch(state.ast.type) {
    case "true":
      this.currentBinding().returnValue = this.world.rTrue.objectId
      return actions.pop(true);
    default: throw(new Error(`Unexpected ast: ${ast.type}`))
  }
}



VM.bootstrap = function(ast) {
  // All Objects
  let nextObjectId = 1
  let allObjects = {
    track: function(toTrack) {
      allObjects[nextObjectId] = toTrack
      toTrack.objectId = nextObjectId
      ++nextObjectId
      return toTrack
    }
  }


  // helpers
  let instantiate = function(klass) {
    let instance = { class: klass.objectId, instanceVariables: {} }
    allObjects.track(instance)
    if(klass.internalInit)
      klass.internalInit(instance)
    return instance
  }

  // BasicObject, Object, Class
  let rClass  = allObjects.track({instanceVariables: {}})
  rClass.class = rClass.objectId

  let rBasicObject = allObjects.track({
    class:             rClass.objectId,
    instanceVariables: {},
  })

  let rObject = allObjects.track({
    class:             rClass.objectId,
    instanceVariables: {},
  })

  rClass.internalInit = function(newClass) {
    newClass.constants       = {}
    newClass.instanceMethods = {}
    newClass.superclass      = rObject.objectId
  }

  rClass.internalInit(rBasicObject)
  rClass.internalInit(rObject)
  rClass.internalInit(rClass)

  rObject.constants["BasicObject"] = rBasicObject.objectId
  rObject.constants["Object"]      = rObject.objectId
  rObject.constants["Class"]       = rClass.objectId


  // true
  let rTrueClass = instantiate(rClass)
  let rTrue      = instantiate(rTrueClass)

  // nil
  let rNilClass = instantiate(rClass)
  let rNil      = instantiate(rNilClass)


  // callstack
  let main = instantiate(rObject)
  let toplevelBinding = {
    localVariables: {},
    self:           main.objectId,
    returnValue:    rNil.objectId,
  }
  let callstack = [toplevelBinding]

  // put it all together
  let world = {
    ast:        ast,
    statestack: [{name: "start", registers: {}}],
    rNil:       rNil,
    rTrue:      rTrue,
    callstack:  callstack,
    allObjects: allObjects
  }

  return new VM(world)
}

module.exports = VM
