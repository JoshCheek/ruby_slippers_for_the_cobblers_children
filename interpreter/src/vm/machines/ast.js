const machine = {
  name: "ast",
  desc: "Hand it an ast, and it identifies which real machine to run, then becomes that machine.",
  type: "abstract",
  registers: {
    "@ast": {type: "hash", hide: true, arg: true}
  },
  // these will be discarded once it is reified
  // it implicitly has a @self register, which makes the decision
  abstract_registers: {
    "@node_type":    {type: "string"}
    "@machine_type": {type: "string"}
    "@candidates":   {
      type: ["machine"], // array of machines
      init: ["ast.true", "ast.false", "ast.nil", "ast.expressions"],
    },
  },
  states: {
    start: {
      setup: [
        ["getKey", "@ast", "type", "@node_type"],        // @node_type = @ast.type
        ["for_in", "@self", "@candidates"],              // @candidates.each { |@self|
        ["getKey", "@self", "type", "@machine_type"],    //   @machine_type = @self.type
        ["break_if_eq", "@machine_type", "@node_type"],  //   break if @machine_type == @node_type
        ["end"]                                          // }
        ["reify", "@self"]                               // self = @self
      ],
    },
  }
}
export machine
