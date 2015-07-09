export default () => {
  return {
    name: "ast.true",
    desc: "Interprets the ast for `true`",
    registers: {
      "@ast":  {type: "hash", hide: true, arg: true},
      "@true": {type: "hash"},
    },
    states: {
      start: {
        body: [
          ["globalToRegister", "$rTrue", "@true"],       // @true = $rTrue
          ["registerToGlobal", "@true", "$returnValue"], // $returnValue = @true
          ["switchStateTo", "finished"],                 // goto :finished
        ]
      }
    }
  }
}
