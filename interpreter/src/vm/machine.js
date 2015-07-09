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
