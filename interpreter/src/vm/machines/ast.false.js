export default () => {
  return {
    name: "ast.false",
    desc: "Interprets the ast for `false`",
    registers: {
      "@ast": {type: "hash", init: {}, hide: true, arg: true},
      "@false": {type: "false"},
    },
    states: {
      start: {
        body: [
          ["globalToRegister", "$rFalse", "@false"],      // @false = $rFalse
          ["registerToGlobal", "@false", "$returnValue"], // $returnValue = @false
          ["switchStateTo", "finished"],                 // goto :finished
        ]
      },
    }
  }
}
