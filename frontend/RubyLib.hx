// Compile and run with:
// haxe -main RubyLib -cp src -js RubyLib.js
// env NODE_PATH=. node run.js

import Stack;
import ruby.ds.Errors;
import ruby.ds.InternalMap;
import ruby.ds.Interpreter;
import ruby.ds.Objects;
import ruby.ds.World;
import ruby.Bootstrap;
import ruby.Core;
import ruby.Http;
import ruby.Interpreter;
import ruby.LanguageGoBag;
import ruby.ParseRuby;
import ruby.World;

// @:native("module") extern class NodeModule { public static var exports:Dynamic; }
// @:native("ruby")   extern class RubyNamespace { }

// Note that the ruby namespace is exported, not this class!!
class RubyLib {
  // don't delete my code just b/c I'm not using it... this is a library!
  // why doesn't `-dce no` do this? :(
  @:keep static public function noDce(rawCode:String) {
    // var worldDs     = ruby.Bootstrap.bootstrap();
    // var world       = new ruby.World(worldDs);
    // var interpreter = world.interpreter;
    // var ast         = ruby.ParseRuby.fromCode(code);
    // Ruby.
    // interpreter.pushCode(ast);
    // trace(world.inspect(interpreter.currentExpression));
    var worldDs     = ruby.Bootstrap.bootstrap();
    var world       = new ruby.World(worldDs);
    var interpreter = world.interpreter;
    var ast         = ruby.ParseRuby.fromCode(rawCode);

    interpreter.pushCode(ast);

    trace("CODE TO INTERPRET: \n" + rawCode);
    trace("--------------------");

    while(interpreter.isInProgress) {
      trace(world.inspect(interpreter.currentExpression));
      interpreter.nextExpression();
    }
    trace("--------------------");
    trace("PRINTED: " + world.printedToStdout);
  }

  public static function main() {
#if js
    untyped __js__("module.exports = ruby;");
    untyped __js__("ruby.RubyLib = RubyLib;");
#end
    var rawCode = 'class User\n' +
                  '  def initialize(name)\n' +
                  '    self.name = name\n' +
                  '  end\n' +
                  '\n'+
                  '  def name\n' +
                  '    @name\n' +
                  '  end\n' +
                  '\n'+
                  '  def name=(name)\n' +
                  '    @name = name\n' +
                  '  end\n' +
                  'end\n' +
                  '\n' +
                  'user = User.new("Josh")\n' +
                  'puts user.name';
    noDce(rawCode);
  }
}
