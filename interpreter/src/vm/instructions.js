"use strict"

import {inspect} from "util"

let doLog = false,
    log   = (pairs) => {
      if(doLog)
        console.log(
          "  " + Object.keys(pairs)
                       .map((key) => `\u001b[33m${key}:\u001b[0m ${inspect(pairs[key])}`)
                       .join(" | ")
        )
    }

export default {
  // eg [ "setInt", "@count", 0 ]
  setInt: (world, machine, registers, register, initialValue) => {
    registers[register] = initialValue
  },

  // eg [ "add", "@count", 1 ]
  add: (world, machine, registers, register, quantity) => {
    if(typeof quantity !== 'number')
      throw(new Error(`Not a numeber! ${quantity}`))
    registers[register] += quantity
  },

  // eg [ "eq", "@areEqual", "@userName", "@prospectName" ]
  eq: (world, machine, registers, toRegister, left, right) => {
    const from   = registers[left],
          to     = registers[right],
          result = (from == to)
    registers[toRegister] = result
  },

  // eg [ "getKey", "@name", "@user", "name" ]
  // note that key may be a direct key, or may be a register
  // (ie calling a key we don't know its value)
  getKey: (world, machine, registers, toRegister, hashRegister, key) => {
    let prevKey = key
    if(key[0] === '@') key = registers[key]

    log({
      registers:    registers,
      toRegister:   toRegister,
      hashRegister: hashRegister,
      initialKey:   prevKey,
      finalKey:     key,
      register:     registers[hashRegister],
    })

    registers[toRegister] = registers[hashRegister][key]
  },


  // "true": {
  //   "name": "true",
  //   "namespace": [
  //     "ast"
  //   ],
  //   "arg_names": [],
  //   "description": "Machine: /ast/true",
  //   "instructions": [
  //  [ "globalToRegister", "rTrue", "@_1" ],
  //  [ "runMachine", [ "emit" ], [ "@_1" ]
  //  ]
  //   ],
  //   "children": {}
  // },

  // eg [ "globalToRegister", "ast", "@_1" ]
  globalToRegister: (world, machine, registers, globalName, registerName) => {
    log({
      globalName: globalName,
      globalValue: world[globalName],
      registerName: registerName,
    })
    registers[registerName] = world[globalName]
  },

  // eg [ "jumpTo", "forloop" ]
  jumpTo: (world, machine, registers, label) => {
    machine.setInstructionPointer(machine.instructionPointerFor(label))
  },

  // eg [ "jumpToIf", "forloop_end", "@_4" ]
  jumpToIf: (world, machine, registers, label, conditionRegister) => {
    if(registers[conditionRegister])
      machine.setInstructionPointer(machine.instructionPointerFor(label))
  },

  // eg [ "label", "forloop_end" ]
  label: (world, machine, registers, label) => {
    // noop
  },

  // eg [ "registerToGlobal", "@_1", "foundExpression" ]
  registerToGlobal: (world, machine, registers, registerName, globalName) => {
    let value = registers[registerName]
    world[globalName] = value
  },

  // eg [ "setKey", "@_1", "returnValue", "@value" ]
  setKey: (world, machine, registers, hashRegister, key, valueRegister) => {
    log({key: key, valueRegister: valueRegister})
    if(key[0] === '@') key = registers[key]
    registers[hashRegister][key] = registers[valueRegister]
  },

  // self <- /ast/@ast.type
  // eg [ "becomeMachine", [ "ast", "@dynamicName"]],
  becomeMachine: (world, machine, registers, path) => {
    let newMachine = world.rootMachine
    path.forEach((name) => {
      if(name[0] === "@")
        newMachine = newMachine.child(registers[name], machine.state.parent)
      else
        newMachine = newMachine.child(name, machine.state.parent)
    })

    newMachine.setArgsFromRegisters(registers)

    world.machineStack = newMachine
  },

  // eg [ "runMachine", [ "emit" ], [ "@_1" ] ]
  runMachine: (world, machine, registers, path, argNames) => {
    let newMachine = world.rootMachine
    path.forEach((name) => {
      if(name[0] === "@")
        newMachine = newMachine.child(registers[name], machine)
      else
        newMachine = newMachine.child(name, machine)
    })

    let args = argNames.map((name) => registers[name])
    log({instantiating: newMachine.name(), withArgs: args})
    newMachine.setArgs(args)

    world.machineStack = newMachine
  },
}
