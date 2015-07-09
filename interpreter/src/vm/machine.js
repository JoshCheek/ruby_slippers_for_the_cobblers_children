"use strict";

let inspect = require("util").inspect


// TODO: type could be abstract, in which case this is probably wrong
const Machine = function(world, state) {
  // console.log(world)
  this.world = world
  this.state = state
}

module.exports = Machine

// execution
Machine.prototype.nextExpression = function() {
  do { this.step() } while(!this.foundExpression)
  return this.currentExpression()
}

Machine.prototype.step = function() {
  this.foundExpression = false
  let call        = this.currentInstructionCall(),
      name        = call[0],
      args        = call.slice(1),
      instruction = this.instructions[name]

  instruction.apply(this, args)
}

// helpers
Machine.prototype.currentInstructionCall = function() {
  let state        = this.currentState(),
      substate     = state.currentSubstate,
      ip           = this.state.instructionPointer,
      instructions = state[substate],
      instruction  = instruction = instructions[ip]

  if(instruction === undefined && substate === 'setup') {
    state.currentSubstate = 'body'
    this.state.instructionPointer = 0
    return this.currentInstructionCall()
  } else if(!instruction) {
    throw(new Error(`No instruction! state:${inspect(state)} substate:${inspect(substate)} ip:${inspect(ip)}`))
  }
  return instruction
}

Machine.prototype.currentState = function() {
  return this.state.states[this.state.currentState]
}

Machine.prototype.currentBinding = function() {
  return this.world.callstack.last
}

Machine.prototype.currentExpression = function() {
  return this.currentBinding().returnValue
}

Machine.prototype.instructions = {
  // @register1 = @hashRegister.key
  getKey: function(valueRegister, key, hashRegister) {
    this.state.registers[valueRegister] = this.state.registers[hashRegister][key]
    this.state.instructionPointer++
  },

  // @hash[:key] = @value
  setKey: function(hashRegister, key, valueRegister) {
    this.state.registers[hashRegister][key] = this.state.registers[valueRegister]
    this.state.instructionPointer++
  },

  // @register = $worldValue
  globalToRegister: function(worldAttr, register) {
    // console.log(this)
    this.state.registers[register] = this.world[worldAttr]
    this.state.instructionPointer++
  },

  // $worldValue = @registerValue
  registerToGlobal: function(register, worldAttr) {
    this.world[worldAttr] = this.state.registers[register]
    this.state.instructionPointer++
  },

  // @machine.init @args
  initMachine: function(machineRegister, argsRegister) {
    throw(new Error("Figure out how to implement me!"))
  },

  // @machine.run
  runMachine: function(machineRegister) {
    throw(new Error("Figure out how to implement me!"))
  },

  // goto stateName
  switchStateTo: function(stateName) {
    this.state.currentState = stateName
    this.state.instructionPointer = 0
  },

  // @ary.each { |@register|
  for_in: function(aryName, register) {
    throw(new Error("Figure out how to implement me!"))
    this.state.instructionPointer++
  },

  end: function() {
    throw(new Error("Figure out how to implement me!"))
    this.state.instructionPointer++
  },

  // break if @register1 == @register2
  break_if_eq: function(register1, register2) {
    throw(new Error("Figure out how to implement me!"))
  },

  // self = @register
  reify: function(register) {
    throw(new Error("Figure out how to implement me!"))
  },
}


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

    // case "getKey": // @register1 = @register2.key
    //   const register1 = instruction[1]
    //         key       = instruction[2]
    //         register2 = instruction[3]
    //   getKey.apply(this, args)
    // case "setKey": // @hash[:key] = @value
    //   const hashRegister  = instruction[1],
    //         key           = instruction[2],
    //         valueRegister = instruction[3]
    // case "globalToRegister": // @register = $worldValue
    //   const worldAttr = instruction[1],
    //         register  = instruction[2]
    // case "initMachine": // @machine.init @args
    //   const machineRegister = instruction[1],
    //         argsRegister    = instruction[2]
    // case "runMachine": // @machine.run
    //   const machineRegister = instruction[1]
    // case "registerToGlobal": // $worldValue = @registerValue
    //   const register = worldAttr
    // case "switchStateTo": // goto stateName
    //   const stateName = instruction[1]
    // case "for_in": // @ary.each { |@register|
    //   const aryName = instruction[1],
    //         register = instruction[2]
    // case "end":
    // case "break_if_eq": // break if @register1 == @register2
    //   const register1 = instruction[1],
    //         register2 = instruction[1]
    // case "reify": // self = @register
    //   const register = instruction[1]
  // }
