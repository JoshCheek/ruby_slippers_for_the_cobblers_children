"use strict";

module.exports = load
const Machine  = require("./machine"),
      machine  = (world, name) => {
        let template = require("./machines/" + name)()
        return new Machine(world, normalize(template))
      }

// loaded this way to prevent modification to the sate from affecting the template
function load(target) {
  target.main            = (world) => machine(world, "main")
  target.ast             = (world) => machine(world, "ast")
  target.ast_nil         = (world) => machine(world, "ast.nil")
  target.true            = (world) => machine(world, "ast.true")
  target.ast_false       = (world) => machine(world, "ast.false")
  target.ast_expressions = (world) => machine(world, "ast.expressions")
  return target
}

function normalize(template) {
  // type / extends
  template.type = template.type || "concrete"
  if(template.type !== "concrete") throw(new Error(`Figure out type: ${template.type}`))
  if(template.extends)             throw(new Error("Figure out extends!"))

  // registers
  template.registers = template.registers || {}
  let registers      = template.registers

  for(var name in registers) {
    let attributes = registers[name]
    if(!attributes) console.log(template, registers, name)
    attributes.type = attributes.type || "any"

    let init = function(value) {
      if(attributes.init === undefined)
        attributes.init = value
    }

    if(attributes.type == "any"       ) init(null)
    if(attributes.type == "hash"      ) init({})
    if(attributes.type == "string"    ) init("")
    if(attributes.type == ["machine"] ) init([])
    if(attributes.type == "machine" && !attributes.init)
      throw(new Error("machines should probably always have an init value, idk what a null machine is"))
  }

  // states
  template.states = template.states || {}
  const states    = template.states
  states.finish   = states.finish || {}
  if(!states.start) throw(new Error("Probably all machines need a start state"))

  for(var name in states) {
    let state             = states[name]
    state.currentSubstate = "setup"
    state.setup           = state.setup || []
    state.body            = state.body  || []
  }

  // starting state
  template.currentState = "start"
  template.instructionPointer = 0

  return template;
}
