"use strict";

import util from "util"
import {inspect} from "util"
import instructionCodes from "./instructions"

let log = (key, value) =>
  console.log(`  \u001b[34m${key}:\u001b[0m ${inspect(value)}`)

export default class Machine {
  constructor(world, state, parent) {
    // console.log(`Defining a machine: ${inspect(state)}`)
    this.world               = world
    this.state               = state

    // TODO: move these into the definitions
    state.parent             = parent
    state.foundExpression    = false
    state.instructionPointer = 0
    state.registers          = {}
    state.labels             = {}
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

  child(name, parent) {
    const definition = this.state.children[name]
    if(!definition) throw(new Error(
      `No child ${inspect(name)} for ${inspect(this.name())}, only have: ${this.state.children.map((child) => child.name)}`
    ))
    return new Machine(this.world, definition, parent)
  }

  nextExpression() {
    let i = 0
    while(true) {
      console.log(`PRE ${this.state.foundExpression}`)
      if(this.step()) {
        console.log(`POST \u001b[42m${this.state.foundExpression}\u001b[0m`)
        return this.currentExpression()
      } else {
        console.log(`POST \u001b[41m${this.state.foundExpression}\u001b[0m`)
      }
      if(i++ > 10)
        throw(new Error(`INFINITY! ${this.name()}`))
    }
  }

  step() {
    const instruction = this.getInstruction()

    if(this.isFinished()) return

    this.state.foundExpression = false
    const name = instruction[0],
          args = instruction.slice(1),
          code = instructionCodes[name]

    console.log(`\n\u001b[44;37m---- ${this.fullname()} ${this.instructionPointer()}:${name} ${inspect(args)} ---------------------------------------------------\u001b[0m`)
    log("pre registers", this.state.registers)

    if(!code)
      throw(new Error(`No instruction: ${name}`))
    else
      code(this.world, this, this.state.registers, ...args)

    this.setInstructionPointer(this.instructionPointer() + 1)
    log("post finished", this.isFinished())
    log("post instructionPointer", this.instructionPointer())
    log("post registers", this.state.registers)
    log("foundExpression", this.state.foundExpression)

    if(this.isFinished())
      this.world.machineStack = this.state.parent

    return this.state.foundExpression
    // if(args[1] === 'foundExpression')
    //   throw(new Error(this.state.foundExpression.toString()))

    // throw(new Error(`code: ${util.inspect(code)}`))
  }

  setInstructionPointer(value) {
    this.state.instructionPointer = value
  }

  name() {
    return this.state.name
  }

  getInstruction() {
    return this.state.instructions[this.instructionPointer()]
  }

  instructionPointer() {
    if(this.state.instructionPointer < 0)
      this.state.instructionPointer = 0
    return this.state.instructionPointer
  }

  currentExpression() {
    return this.world.currentBinding.returnValue
  }

  fullname() {
    let ns = this.state.namespace.slice(0)
    ns.unshift("")
    ns.push(this.name())
    return ns.join('/')
  }

  isFinished() {
    return !this.getInstruction()
  }
}
