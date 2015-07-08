// assume all machines have hidden access to the world, ie can reference any toplevel attribute of world
// all machines implicitly have a setup pseudo-state, where they start,
//   its job is to initialize the machine and put it into the start state
//   the setup state will not be run as part of the machine, whatever state it advances to, will be the starting state
// finish states and error must be declared, so that we know externally when the machine is done, and can manage the wiring of machines using other machines
// error states are also finish states
// no code may go in the finished state, once you are there, you are there, unless the machine is used while in the finish state, then it transitions into an error state
//
// bytecode notation:
// $whatever means `whatever` is an attribute on world
// @whatever means `whatever` is a register on the machine

process: // as in the "ruby process"
  registers:
    @astMachine:     {type: :machine, init: :ast, hide: true}
    @astMachineArgs: {type: :hash,    init: {},   hide: true}
    @ast:            {type: :hash,    init: {},   hide: true}
  states:
    start:
      body: ["goto :running"]
    running:
      setup: [
        "@ast = $ast"
        "@astMachineArgs[:ast] = @ast"
        "@astMachine.init @astMachineArgs"
        "@astMachine.run"
      ]
      body: ["goto :finished"]

ast:
  type: :abstract
  registers:
    @ast: {type: :hash, hide: true, arg: true}

  // this machine will be run to identify which real ast machine to run
  // its registers will be discarded once it is done
  // it implicitly has a @self register, which makes the decision
  find_self:
    registers:
      @node_type:    {type: :string, init: "@ast.type"}
      @machine_type: {type: :string}
      @candidates:   {
        type: [:machine],
        init: [:ast.true, :ast.false, :ast.nil, :ast.expressions]
      }
    states:
      start:
        setup: [
          "for @self in @candidates"
            "@machine_type = @astMachine.type"
            "@machine_type == @node_type"
            "break_if"
          "end"
          "reify @self"
        ]

ast.true:
  extends: :ast
  registers:
    @true: {}
  states:
    body:
      "@true = $rTrue"
      "$returnValue = @true"
      "goto :finished"

ast.false:
  extends: ast
  registers:
    @false: {}
  states:
    body:
      "@false = $rFalse"
      "$returnValue = @false"
      "goto :finished"

ast.nil:
  extends: ast
  registers:
    @nil:   {}
  states:
    body:
      "@nil = $rNil"
      "$returnValue = @nil"
      "goto :finished"

ast.expressions:
  // state.substateStack = []
  // state.expressions = ast.expressions.map((child) => astMachine(vm, child))
  extends: ast
  registers:
    @expression: {}
    @node_type:  {type: :hash}
    @child:      {type: :machine, init: :ast}
  states:
    start:
      body: [
        "@nil = $rNil"
        "$returnValue = @nil"
        "goto :running"
      ]
    running:
      body: [
        "for @expression in @expressions"
          @child.init {ast: @expression}
          @child.run
        "end"
        "goto :finished"
      ]
