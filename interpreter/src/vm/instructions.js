"use strict"

export default {
  setInt: (world, machine, registers, register, initialValue) => {
    registers[register] = initialValue
  },

  add: (world, machine, registers, register, quantity) => {
    if (typeof quantity !== 'number')
      throw (new Error(`Not a numeber! ${quantity}`))
    registers[register] += quantity
  },

  eq: (world, machine, registers, toRegister, left, right) => {
    registers[toRegister] = (registers[left] == registers[right])
  },

  getKey: (world, machine, registers, toRegister, hashRegister, key) => {
    if (key[0] === '@') key = registers[key]
    registers[toRegister] = registers[hashRegister][key]
  },

  globalToRegister: (world, machine, registers, globalName, registerName) => {
    registers[registerName] = world[globalName]
  },

  jumpTo: (world, machine, registers, label) => {
    machine.setInstructionPointer(machine.instructionPointerFor(label))
  },

  jumpToIf: (world, machine, registers, label, conditionRegister) => {
    if (registers[conditionRegister])
      machine.setInstructionPointer(machine.instructionPointerFor(label))
  },

  label: (world, machine, registers, name) => {
    /* noop */
  },

  registerToGlobal: (world, machine, registers, registerName, globalName) => {
    let value = registers[registerName]
    world[globalName] = value
  },

  setKey: (world, machine, registers, hashRegister, key, valueRegister) => {
    if (key[0] === '@') key = registers[key]
    registers[hashRegister][key] = registers[valueRegister]
  },

  becomeMachine: (world, machine, registers, path) => {
    let newMachine = world.rootMachine
    path.forEach((name) => {
      if (name[0] === "@")
        newMachine = newMachine.child(registers[name], machine.state.parent)
      else
        newMachine = newMachine.child(name, machine.state.parent)
    })
    newMachine.setArgsFromRegisters(registers)
    world.machineStack = newMachine
  },

  runMachine: (world, machine, registers, path, argNames) => {
    let newMachine = world.rootMachine
    path.forEach((name) => {
      if (name[0] === "@")
        newMachine = newMachine.child(registers[name], machine)
      else
        newMachine = newMachine.child(name, machine)
    })
    let args = argNames.map((name) => registers[name])
    newMachine.setArgs(args)
    world.machineStack = newMachine
  },

}
