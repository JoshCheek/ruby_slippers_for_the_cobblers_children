// Compile and run with:
// haxe -main RubyLib -cp src -js RubyLib.js
// env NODE_PATH=. node run.js

import ruby.*;
import ruby.ds.*;

@:native("module") extern class NodeModule { public static var exports:Dynamic; }
@:native("ruby")   extern class RubyNamespace { }

class RubyLib {
  // don't delete my code just b/c I'm not using it... this is a library!
  // why doesn't `-dce no` do this? :(
  @:keep static function noDce() {
    var worldDs     = ruby.Bootstrap.bootstrap();
    var world       = new ruby.World(worldDs);
    var interpreter = world.interpreter;
    trace(world.inspect(interpreter.currentExpression)); // #<NilClass>
  }

  public static function main() {
    NodeModule.exports = RubyNamespace;
  }
}
