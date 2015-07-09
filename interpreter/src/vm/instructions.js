export default {
  // @register1 = @hashRegister.key
  getKey: function(valueRegister, key, hashRegister) {
    this.state.registers[valueRegister] = this.state.registers[hashRegister][key]
    this.state.instructionPointer++
  },

  // @hash[:key] = @value
  setKey: function(hashRegister, key, valueRegister) {
    this.state.registers[hashRegister][key] = this.state.registers[valueRegister]
    this.state.instructionPointer++
  },

  // @register = $worldValue
  globalToRegister: function(worldAttr, register) {
    // console.log(this)
    this.state.registers[register] = this.world[worldAttr]
    this.state.instructionPointer++
  },

  // $worldValue = @registerValue
  registerToGlobal: function(register, worldAttr) {
    this.world[worldAttr] = this.state.registers[register]
    this.state.instructionPointer++
  },

  // @machine.init @args
  initMachine: function(machineRegister, argsRegister) {
    throw(new Error("Figure out how to implement me!"))
  },

  // @machine.run
  runMachine: function(machineRegister) {
    throw(new Error("Figure out how to implement me!"))
  },

  // goto stateName
  switchStateTo: function(stateName) {
    this.state.currentState = stateName
    this.state.instructionPointer = 0
  },

  // @ary.each { |@register|
  for_in: function(aryName, register) {
    throw(new Error("Figure out how to implement me!"))
    this.state.instructionPointer++
  },

  end: function() {
    throw(new Error("Figure out how to implement me!"))
    this.state.instructionPointer++
  },

  // break if @register1 == @register2
  break_if_eq: function(register1, register2) {
    throw(new Error("Figure out how to implement me!"))
  },

  // self = @register
  reify: function(register) {
    throw(new Error("Figure out how to implement me!"))
  },
}
