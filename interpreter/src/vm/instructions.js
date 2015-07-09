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
    console.log(machineRegister, argsRegister)
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
    // console.log(this.state)
    // check the index, if it's too far, jump to the end
    // otherwise, set the first arg to be the current item in the second arg
    // and then increment the index
    this.state.instructionPointer++
    throw(new Error("Figure out how to implement me!"))
  },

  end: function() {
    // update the instructionPointer to be the start index
    throw(new Error("Figure out how to implement me!"))
    this.state.instructionPointer++
  },

  // break if @register1 == @register2
  break_if_eq: function(register1, register2) {
    // compare the two things, if they are equal,
    // set the instructionPointer to be the `end` index
    throw(new Error("Figure out how to implement me!"))
  },

  // self = @register
  reify: function(register) {
    throw(new Error("Figure out how to implement me!"))
  },
}
