package ruby;

import haxe.unit.TestRunner;

class RunTests {
  public static function addTests(runner:TestRunner):TestRunner {
    var envVarName = "RUBY_PARSER_PORT";
    if(Sys.environment().exists(envVarName)) {
      var port = Sys.environment().get(envVarName);
      ruby.ParseRuby.serverUrl = 'http://localhost:$port';
    } else {
      throw 'Need to set the port to find the server in env var $envVarName';
    }

    runner.add(new TestSupport());
    runner.add(new TestInterpreter());

    return runner;
  }

  static function main() {
    var runner    = addTests(new TestRunner());
    var allPassed = runner.run();
    if(!allPassed) Sys.exit(1);
  }
}
