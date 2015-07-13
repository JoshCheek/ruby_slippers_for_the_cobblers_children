"use strict";

import util from "util"
import {inspect} from "util"
import instructionCodes from "./instructions"

let log = (key, value) =>
  console.log(`  \u001b[34m${key}:\u001b[0m ${inspect(value)}`)

export default class Machine {
  constructor(world, state) {
    // console.log(`Defining a machine: ${inspect(state)}`)
    this.isFinished          = false
    this.world               = world
    this.state               = state

    // TODO: move these into the definitions
    state.foundExpression = false
    state.instructionPointer = 0
    state.registers = {}
    state.labels    = {}
    state.instructions.forEach(
      ([instr, name], index) => {
        if(instr === "label")
          state.labels[name] = index
    })
  }

  setArgs(args) {
    let l1 = args.length, l2 = this.state.arg_names.length
    if(l1 != l2) throw(new Error(`LENGTHS DO NOT MATCH! expected:${l2}, actual:${l1}`))

    this.state.arg_names.forEach((argName, index) => {
      this.state.registers[argName] = args[index]
    })
  }

  child(name) {
    const definition = this.state.children[name]
    // console.log(`FINDING CHILD: ${name}: ${inspect(definition)}`)
    return new Machine(this.world, definition)
  }

  nextExpression() {
    while(true) {
      console.log(`PRE ${this.state.foundExpression}`)
      this.step()
      if(this.state.foundExpression)
        console.log(`POST \u001b[42m${this.state.foundExpression}\u001b[0m`)
      else
        console.log(`POST \u001b[41m${this.state.foundExpression}\u001b[0m`)
      if(this.state.foundExpression || this.isFinished)
        return this.currentExpression()
    }
  }

  step() {
    const instruction = this.getInstruction()

    if(this.isFinished) return

    this.state.foundExpression = false
    const name = instruction[0],
          args = instruction.slice(1),
          code = instructionCodes[name]

    console.log(`\n\u001b[44;37m---- ${this.fullname()} ${this.state.instructionPointer}:${name} ${inspect(args)} ---------------------------------------------------\u001b[0m`)
    log("pre instructionPointer", this.state.instructionPointer)
    log("pre registers", this.state.registers)

    if(!code)
      throw(new Error(`No instruction: ${name}`))
    else
      code(this.world, this, this.state.registers, ...args)

    this.state.instructionPointer++
    log("post finished", this.isFinished)
    log("post instructionPointer", this.state.instructionPointer)
    log("post registers", this.state.registers)
    log("foundExpression", this.state.foundExpression)
    // if(args[1] === 'foundExpression')
    //   throw(new Error(this.state.foundExpression.toString()))

    // throw(new Error(`code: ${util.inspect(code)}`))
  }

  currentChild() {
    return this.state.currentChild
  }

  setCurrentChild(child) {
    this.state.currentChild = child
  }

  deleteCurrentChild() {
    delete this.state.currentChild
  }

  doNotAdvance() {
    this.state.instructionPointer--
  }

  setInstructionPointer(value) {
    this.state.instructionPointer = value
  }

  name() {
    return this.state.name
  }

  getInstruction() {
    if(this.state.instructionPointer < 0)
      this.state.instructionPointer = 0
    const instructionPointer = this.state.instructionPointer,
          instruction        = this.state.instructions[instructionPointer]
    if(!instruction) this.isFinished = true
    return instruction
  }

  currentExpression() {
    return this.world.currentBinding.returnValue
  }

  fullname() {
    let ns = this.state.namespace.slice(0)
    ns.unshift("")
    ns.push(this.state.name)
    return ns.join('/')
  }
}
