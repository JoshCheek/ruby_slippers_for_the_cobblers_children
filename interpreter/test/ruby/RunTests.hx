package ruby;

class RunTests {
  static function main() {
    var r = new haxe.unit.TestRunner();
    r.add(new TestLanguageGoBag());
    r.add(new TestParser());
    r.add(new TestSupport());
    r.add(new TestBootstrappedWorld());
    r.add(new TestWorld());
    r.add(new TestInterpreter());
    r.run();
  }
}
