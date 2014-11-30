// from http://haxe.org/manual/lf-metadata.html
import haxe.rtti.Meta;

@author("Nicolas")  // author: ["Nicolas"]
@debug              // debug:  null
class MyClass {
  @range(1, 8)   // range: [1, 8]
  var value:Int;

  @broken        // broken: null
  @:noCompletion // leading colon means this is a compiler macro, so won't see it below
  static function method() { }
}

class MetadataExample {
  static public function main() {
    var klass:Class<Dynamic> = MyClass; // not sure if there's a better way to do this

    trace(Meta.getType(klass));               // { author : ["Nicolas"], debug : null }
    trace(Meta.getFields(klass).value.range); // [1,8]
    trace(Meta.getStatics(klass).method);     // { broken: null }
  }
}
