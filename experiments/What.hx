// dir.ModuleStyleMethods shows how packaging is done
// we can use `using` to make its methods callable on our objects
using dir.ModuleStyleMethods;

enum Something {
  Arys(a:Array<String>);
}

class What {
  static function main() {
    // dir.ModuleStyleMethods.zomg(1, "called on module"); // using the packages (this is probably worth putting into haxe examples)
    new What().zomg("called on another instance");   // Module style

    var arys = Arys(["a", "b"]);
    switch(arys) {
      case Arys(a):
        trace("MATCH: " + Std.string(a));
        a.push("c");
        trace("MATCH: " + Std.string(a));
      case _:
        trace("NO MATCH");
    }
    switch(arys) {
      case Arys(b):
        trace("MATCH: " + Std.string(b));
      case _:
        trace("NO MATCH: ");
    }

  }

  public function new() null;
}
