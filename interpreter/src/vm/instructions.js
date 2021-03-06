"use strict"

import {
  inspect
}
from 'util'

let constructMachine = function (definition, parent) {
  return {
    definition: definition,
    parent: parent,
    registers: {},
    instructionPointer: 0,
  }
}

let _newMachine = function (root, path, registers, parent) {
  let machineDef = root
  path.forEach((name) => {
    let registerName = (name[0] === '@' ? registers[name] : name)
    machineDef = machineDef.children[registerName]
    if (!machineDef)
      throw (new Error(`No machine ${inspect(name)} -> ${inspect(registerName)} in ${inspect(path)}`))
  })
  return constructMachine(machineDef, parent)
}

export default {
  setInt: (world, state, machine, registers, register, initialValue) => {
    registers[register] = initialValue
  },

  add: (world, state, machine, registers, register, quantity) => {
    if (typeof quantity !== 'number')
      throw (new Error(`Not a numeber! ${quantity}`))
    registers[register] += quantity
  },

  eq: (world, state, machine, registers, toRegister, left, right) => {
    registers[toRegister] = (registers[left] == registers[right])
  },

  getKey: (world, state, machine, registers, toRegister, hashRegister, key) => {
    if (key[0] === '@') key = registers[key]
    let register = registers[hashRegister][key]
    registers[toRegister] = register
  },

  globalToRegister: (world, state, machine, registers, globalName, registerName) => {
    if (world[globalName] === undefined)
      throw (new Error(`No global ${globalName} in globalToRegister`))
    registers[registerName] = world[globalName]
  },

  jumpTo: (world, state, machine, registers, label) => {
    state.instructionPointer = state.definition.labels[label]
  },

  jumpToIf: (world, state, machine, registers, label, conditionRegister) => {
    if (registers[conditionRegister])
      state.instructionPointer = state.definition.labels[label]
  },

  label: (world, state, machine, registers, name) => {
    /* noop */
  },

  registerToGlobal: (world, state, machine, registers, registerName, globalName) => {
    let value = registers[registerName]
    world[globalName] = value
  },

  registerToRegister: (world, state, machine, registers, from, to) => {
    registers[to] = registers[from]
  },

  setKey: (world, state, machine, registers, hashRegister, key, valueRegister) => {
    if (key[0] === '@') key = registers[key]
    registers[hashRegister][key] = registers[valueRegister]
  },

  becomeMachine: (world, state, machine, registers, path) => {
    // Note: parent is only necessary for popping, as we don't retain a real stack.
    let newMachine = _newMachine(world.$rootMachine, path, registers, state.parent)

    newMachine.definition.arg_names.forEach((argName) => {
      if (!registers[argName])
        throw (new Error(`Expected register ${argName}, but only had: ${inspect(Object.keys(registers))}`))
      newMachine.registers[argName] = registers[argName]
    })
    world.$machineStack = newMachine
  },

  runMachine: (world, state, machine, registers, path, argNames) => {
    let newMachine = _newMachine(world.$rootMachine, path, registers, state)
    let args = argNames.map((name) => registers[name])

    let l1 = args.length,
      l2 = newMachine.definition.arg_names.length
    if (l1 != l2) throw (new Error(`LENGTHS DO NOT MATCH! expected:${l2}, actual:${l1}`))

    newMachine.definition.arg_names.forEach((argName, index) => {
      newMachine.registers[argName] = args[index]
    })

    world.$machineStack = newMachine
  },

  newHash: (world, state, machine, registers, register) => {
    registers[register] = {}
  },

  aryAppend: (world, state, machine, registers, aryRegister, toAppendRegister) => {
    registers[aryRegister].push(registers[toAppendRegister])
  },

  to_bool: (world, state, machine, registers, bool_register, from_register) => {
    registers[bool_register] = !!registers[from_register]
  },

  not: (world, state, machine, registers, negated_register, bool_register) => {
    registers[negated_register] = !registers[bool_register]
  },

}
