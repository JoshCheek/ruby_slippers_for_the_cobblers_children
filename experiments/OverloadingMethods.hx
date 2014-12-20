// works with Java, not with Necko or JavaScript
//
// eg: $ haxe -main OverloadingMethods -java OverloadingMethodsJava
//     $ java -jar OverloadingMethodsJava/OverloadingMethods.jar
//
// lots of examples here: https://github.com/HaxeFoundation/haxe/blob/b84ca37d1d5ebc0c7af9a3c0c8408d4f9b853879/tests/unit/src/unit/TestOverloads.hx
// including different return types, different arity, different param types.
class DifferentTypes {
  public function new() {};

  @:overload public function double(n:Int):Int {
    return n*2;
  }

  @:overload public function double(s:String):String {
    return s+s;
  }
}


class OverloadingMethods {
  public static function main() {
    var differentTypes = new DifferentTypes();
    trace(differentTypes.double(100)); // 200
    trace(differentTypes.double('abc')); // 'abcabc'

    // var differentArity = new DifferentArity();
    // trace(differentArity.multiply(5));     // 25
    // trace(differentArity.multiply(5, 10)); // 50

    // var differentReturnType = new DifferentReturnType();

  }
}
