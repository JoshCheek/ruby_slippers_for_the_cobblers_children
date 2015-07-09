export default function step(vm, statestack) {
  const state       = statestack[statestack.length-1]
  const resultState = stepMain(vm, state)
  return handleStepResult(vm, statestack, state, resultState)
}

step.actions = {
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

function handleStepResult(vm, statestack, state, resultState) {
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

function stepMain(vm, state) {
  const actions    = step.actions
  switch(state.name) {
    case "start":
      state.substateStack = [astMachine(vm, vm.world.ast)]
      return actions.advance("running")

    case "running":
      const substack        = state.substateStack
      if(substack.length == 0) return actions.advance("finished")
      const state           = substack[substack.length-1]
      const expressionFound = handleStepResult(vm,
                                               substack,
                                               state,
                                               stepAst(vm, state)
                                              )
      return actions.noop(expressionFound)

    case "finished":
      vm.setCurrentExpression(vm.world.rNil)
      return actions.noop(true)

    default: throw(new Error(`Unexpected state: ${JSON.stringify(state)}`))
  }
}

function astMachine(vm, ast) {
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
      state.expressions = ast.expressions.map((child) => astMachine(vm, child))
    case "nil":
    case "true":
    case "false":
      break
    default: throw(new Error(`Unexpected ast: ${ast.type}`))
  }
  return state
}

function stepAst(vm, state) {
  const actions = step.actions
  switch(state.ast.type) {
    case "true":
      vm.setCurrentExpression(vm.world.rTrue)
      return actions.pop(true);

    case "nil":
      vm.setCurrentExpression(vm.world.rNil)
      return actions.pop(true)

    case "expressions":
      const substack = state.substateStack
      if(substack.length == 0 && state.expressions.length == 0)
        return actions.pop(true)

      if(substack.length == 0)
        substack.push(state.expressions.shift())

      const state           = substack[substack.length-1]
      const expressionFound = handleStepResult(vm, substack, state, stepAst(vm, state))
      return actions.noop(expressionFound)

    default: throw(new Error(`Unexpected ast: ${JSON.stringify(state.ast)}`))
  }
}
