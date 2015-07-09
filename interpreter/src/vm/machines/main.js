export default () => {
  return {
    name: "main",
    desc: "The main machine, kicks everything else off",
    registers: {
      "@astMachine":     {type: "machine", init: "ast", hide: true},
      "@ast":            {type: "hash",    init: {},    hide: true},
      "@astMachineArgs": {type: "hash",    init: {},    hide: true},
    },
    states: {
      start: {
        body: [
          ["switchStateTo", "running"],
        ],
      },
      running: {
        setup: [
          ["globalToRegister", "$ast", "@ast"],              // @ast = $ast
          ["setKey", "@astMachine", "ast", "@ast"],          // @astMachineArgs[:ast] = @ast
          ["initMachine", "@astMachine", "@astMachineArgs"], // @astMachine.init @astMachineArgs
          ["runMachine",  "@astMachine"],                    // @astMachine.run
        ],
        body: [
          ["switchStateTo", "finished"] // "goto :finished"
        ],
      },
    }
  }
}
