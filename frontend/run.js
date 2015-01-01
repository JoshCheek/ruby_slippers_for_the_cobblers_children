// Apparently "inspect" is used by node.js
// which is reasonable, really, glad they did that
// but still, means that this stuff tends to explode b/c I defined it, also, but not for that purpose,
// and it explodes unhelpfully b/c they call it with the wrong number of args, so param is null -.-
(function() {
  // var rawCode = 'class User\n' +
  //               '  def initialize(name)\n' +
  //               '    self.name = name\n' +
  //               '  end\n' +
  //               '\n'+
  //               '  def name\n' +
  //               '    @name\n' +
  //               '  end\n' +
  //               '\n'+
  //               '  def name=(name)\n' +
  //               '    @name = name\n' +
  //               '  end\n' +
  //               'end\n' +
  //               '\n' +
  //               'user = User.new("Josh")\n' +
  //               'puts user.name';
  var ruby        = require("RubyLib");
  // var worldDs     = ruby.Bootstrap.bootstrap();
  // var world       = new ruby.World(worldDs);
  // var interpreter = world.interpreter;
  // var ast         = ruby.ParseRuby.fromCode(rawCode);

  // interpreter.pushCode(ast);

  // console.log("CODE TO INTERPRET: \n" + rawCode);
  // console.log("--------------------");

  // // while(interpreter.get_isInProgress()) {
  //   console.log(world.inspect(interpreter.get_currentExpression()));
  //   interpreter.nextExpression();
  // // }
  // console.log("--------------------");
  // console.log("PRINTED: " + world.printedToStdout);
})();
