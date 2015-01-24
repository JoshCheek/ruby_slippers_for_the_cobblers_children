class MiddleOptional {
  public static function f(string:String, ?struct:Dynamic, ?fn:Void->Void) {
    // it's not actually smart enough to realize the third arg goes to fn and
    // it's the middle one that's missing so we have to make them both optional,
    // and then check for it and move the middle one to the end in that case.
    // I really don't understand why.
    if(fn == null) {
      fn = struct;
      struct = {};
    }

    trace('STRING: ${string}');
    trace('STRUCT: ${struct}');
    trace('FN:     ${fn}');
    trace("-----------------------");
  }

  public static function main() {
    f("a", {}, function() {});
    f("a", function() {});
  }
}
