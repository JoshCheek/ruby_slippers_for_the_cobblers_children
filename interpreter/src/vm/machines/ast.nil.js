const machine = {
  name: "ast.nil",
  desc: "Interprets the ast for `nil`",
  registers: {
    "@ast": {type: "hash", init: {}, hide: true, arg: true},
    "@nil": {type: "hash"},
  },
  states: {
    start: {
      body: [
        ["globalToRegister", "rNil", "@nil"],        // @nil = $rNil
        ["registerToGlobal", "@nil", "returnValue"], // $returnValue = @nil
        ["switchStateTo", "finished"],               // goto :finished
      ]
    },
  }
}
export machine
