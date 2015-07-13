"use strict";

import util from "util"
import {inspect} from "util"
import instructionCodes from "./instructions"

let doLog = true,
    log   = (pairs) => {
      if(doLog)
        console.log(
          "  " + Object.keys(pairs)
                       .map((key) => `\u001b[34m${key}:\u001b[0m ${inspect(pairs[key])}`)
                       .join(" | ")
        )
    }

export default class Machine {
  constructor(world, state, parent) {
    this.world               = world
    this.state               = state

    // TODO: move these into the definitions
    state.parent             = parent
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

  setArgsFromRegisters(registers) {
    this.state.arg_names.forEach((argName) => {
      if(!registers[argName])
        throw(new Error(`Expected register ${argName}, but only had: ${inspect(Object.keys(registers))}`))
      this.state.registers[argName] = registers[argName]
    })
  }

  child(name, parent) {
    const definition = this.state.children[name]
    if(!definition) throw(new Error(
      `No child ${inspect(name)} for ${inspect(this.name())}, only have: ${this.state.children.map((child) => child.name)}`
    ))
    return new Machine(this.world, definition, parent)
  }

  step() {
    if(this.isFinished()) throw(new Error(`${this.name()} is finished!`))

    const instruction = this.getInstruction(),
          name        = instruction[0],
          args        = instruction.slice(1),
          code        = instructionCodes[name],
          stackNames  = []

    let machine = this.world.machineStack
    while(machine) {
      stackNames.push(machine.fullname())
      machine = machine.parent()
    }


    console.log(`\n\u001b[35mSTACK: \u001b[0m${stackNames.join(", ")}`)
    console.log(`\u001b[44;37m---- ${this.fullname()} ${this.instructionPointer()}:${name} ${inspect(args)} ---------------------------------------------------\u001b[0m`)
    log({preRegisters: this.state.registers})

    if(!code)
      throw(new Error(`No instruction: ${name}`))
    else
      code(this.world, this, this.state.registers, ...args)

    this.setInstructionPointer(this.instructionPointer() + 1)

    log({
      name:                   this.name(),
      postFinished:           this.isFinished(),
      postInstructionPointer: this.instructionPointer(),
      postRegisters:          this.state.registers,
      foundExpression:        this.world.foundExpression,
    })
  }

  parent() {
    return this.state.parent
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

  instructionPointerFor(label) {
    return this.state.labels[label]
  }
}
