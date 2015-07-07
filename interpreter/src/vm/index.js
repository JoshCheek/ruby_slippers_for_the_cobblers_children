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

VM.prototype.setCurrentExpression = function(value) {
  this.currentBinding().returnValue = value.objectId
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
      const substack        = state.substateStack
      if(substack.length == 0) return actions.advance("finished")
      const state           = substack[substack.length-1]
      const expressionFound = this.handleStepResult(substack, state, this.stepAst(state))
      return actions.noop(expressionFound)

    case "finished":
      this.setCurrentExpression(this.world.rNil)
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

  // note to self: these fall through
  switch(ast.type) {
    case "expressions":
      state.substateStack = []
      state.expressions = ast.expressions.map((child) => this.astMachine(child))
    case "nil":
    case "true":
    case "false":
      break
    default: throw(new Error(`Unexpected ast: ${ast.type}`))
  }
  return state
}

VM.prototype.stepAst = function(state) {
  const actions = this.step.actions
  switch(state.ast.type) {
    case "true":
      this.setCurrentExpression(this.world.rTrue)
      return actions.pop(true);

    case "nil":
      this.setCurrentExpression(this.world.rNil)
      return actions.pop(true)

    case "expressions":
      const substack = state.substateStack
      if(substack.length == 0 && state.expressions.length == 0)
        return actions.pop(true)

      if(substack.length == 0)
        substack.push(state.expressions.shift())

      const state           = substack[substack.length-1]
      const expressionFound = this.handleStepResult(substack, state, this.stepAst(state))
      return actions.noop(expressionFound)

    default: throw(new Error(`Unexpected ast: ${JSON.stringify(state.ast)}`))
  }
}

var buildWorld = require('./build_world')
VM.bootstrap = function(ast) {
  return new VM(buildWorld(ast))
}

module.exports = VM
