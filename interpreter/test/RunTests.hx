class RunTests {
  static function main() {
    var r = new haxe.unit.TestRunner();
    r.add(new ruby.TestLanguageGoBag());
    r.add(new ruby.TestParser());
    r.add(new ruby.TestSupport());
    r.add(new ruby.TestBootstrappedWorld());
    r.add(new ruby.TestWorld());
    r.add(new ruby.TestInterpreter());
    r.run();
  }
}
