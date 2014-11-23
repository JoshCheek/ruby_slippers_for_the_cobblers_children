class TestInterpreter extends haxe.unit.TestCase {
  // https://github.com/JoshCheek/ruby_object_model_viewer/tree/5204eb089329b387353da0c25016328c55fba369/haxe-testing-example
  //   simple example of a test suite
  //
  // http://api.haxe.org/haxe/unit/index.html
  //   test suite api
  //
  // http://api.haxe.org/
  //   language api

  var filepath: String;

  override public function setup() {
    filepath = "../example-json-to-evaluate.json";
  }

  // this only finds the json if you are in the current dir (e.g. via rake)
  // not sure how to get the location of this file, specifically
  public function testAacceptance1() {
    var body = sys.io.File.getContent(filepath);
    var json = haxe.Json.parse(body);
    print(json);
    // PROCESS (in Ruby for now, I'll translate it before I go to write the test):
    //   stdout      = StringIO.new
    //   interpreter = Interpreter.new(stdout: stdout)
    //   interpreter.add_code(JSON.parse File.read filepath);
    //   interpreter.eval_all
    //   assert_equal "Josh", stdout.string
    //   user_class = interpreter.lookup_class(:User).
    //   assert_equal :User, user_class.name
    //   assert_equal [:initialize, :name, :name=], user_class.instance_methods(false)
    //   assert_equal 1, interpreter.lookup_class(:ObjectSpace).each_object(user_class).size
    assertTrue(true);
  }
}
