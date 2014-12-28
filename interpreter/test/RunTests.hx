class RunTests {
  static function main() {
    var envVarName = "RUBY_PARSER_PORT";
    if(Sys.environment().exists(envVarName)) {
      var port = Sys.environment().get(envVarName);
      ruby.ParseRuby.serverUrl = 'http://localhost:$port';
    } else {
      throw 'Need to set the port to find the server in env var $envVarName';
    }

    var r = new haxe.unit.TestRunner();
    r.add(new TestStack());
    r.add(new ruby.TestLanguageGoBag());
    r.add(new ruby.TestParser());
    r.add(new ruby.TestSupport());
    r.add(new ruby.TestBootstrappedWorld());
    r.add(new ruby.TestWorld());
    r.add(new ruby.TestInterpreter());
    r.run();
  }
}
