"use strict";

import {inspect} from "util"
import instructions from "./instructions";

// TODO: type could be abstract, in which case this is probably wrong
export default class Machine {
  constructor(world, state) {
    this.world = world
    this.state = state
  }

  nextExpression() {
    do { this.step() } while(!this.foundExpression)
    return this.currentExpression()
  }

  step() {
    this.foundExpression = false
    let call        = this.currentInstructionCall(),
        name        = call[0],
        args        = call.slice(1),
        instruction = instructions[name]

    console.log(`${inspect(instruction)} ${inspect(instructions)}`)

    instruction.apply(this, args)
  }

  // helpers
  currentInstructionCall() {
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

  currentState() {
    return this.state.states[this.state.currentState]
  }

  currentBinding() {
    return this.world.callstack.last
  }

  currentExpression() {
    return this.currentBinding().returnValue
  }
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
