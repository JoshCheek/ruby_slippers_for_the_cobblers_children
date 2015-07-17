"use strict"
import buildWorld from './build_world'
import instructionCodes from "./instructions"
import {inspect} from 'util'

export default class VM {
  constructor(world) {
    this.world = world
  }

  static bootstrap(ast) {
    return new VM(buildWorld(ast))
  }

  runToEnd() {
    let expressions = []
    while(this.world.$machineStack)
      expressions.push(this.nextExpression())
    return expressions
  }

  currentBinding() {
    return this.world.$currentBinding
  }

  nextExpression() {
    this.world.$foundExpression = false
    while(!this.world.$foundExpression && this.world.$machineStack) {
      this.step(this.world.$machineStack)

      while(this.world.$machineStack && this.isFinished(this.world.$machineStack))
        this.world.$machineStack = this.world.$machineStack.parent
    }

    return this.currentExpression()
  }

  currentExpression() {
    return this.currentBinding().returnValue
  }

  setCurrentExpression(value) {
    this.currentBinding().returnValue = value
  }

  step(machine) {
    if(this.isFinished(machine)) throw(new Error(`${machine.definition.name()} is finished!`))

    const instruction = this.getInstruction(machine),
          name        = instruction[0],
          args        = instruction.slice(1),
          code        = instructionCodes[name]

    // console.log(`INSTRUCTION: ${machine.definition.name}:${name}\t${inspect(args)}`)

    if(!code)
      throw(new Error(`No instruction: ${name}`))
    else
      code(this.world, machine, "DO NOT USE THIS!!", machine.registers, ...args)

    machine.instructionPointer = this.instructionPointer(machine) + 1
  }

  getInstruction(machine) {
    return machine.definition.instructions[this.instructionPointer(machine)]
  }

  instructionPointer(machine) {
    if(machine.instructionPointer < 0)
      machine.instructionPointer = 0
    return machine.instructionPointer
  }

  isFinished(machine) {
    return !this.getInstruction(machine)
  }
}
