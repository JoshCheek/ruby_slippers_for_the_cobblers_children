// This is just here so I can look at the generated code
// to see how decisions I make affect it.
// Generate with: haxe -main F -cp src -cp test --interp
import ruby.Interpreter;
using ruby.WorldWorker;

class F {
  public static function main() {
    var interpreter = Interpreter.fromBootstrap();
    trace(interpreter.currentExpression());
  }
}
