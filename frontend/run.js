// Apparently "inspect" is used by node.js
// which is reasonable, really, glad they did that
// but still, means that this stuff tends to explode b/c I defined it, also, but not for that purpose,
// and it explodes unhelpfully b/c they call it with the wrong number of args, so param is null -.-
(function() {
var ruby              = require("RubyLib");
var worldDs           = ruby.Bootstrap.bootstrap();
var world             = new ruby.World(worldDs);
var interpreter       = world.interpreter;
var currentExpression = interpreter.get_currentExpression() // b/c the currentExpression property is abstract, this is the underlying implementation
console.log(world.inspect(currentExpression)); // #<NilClass>
})();
