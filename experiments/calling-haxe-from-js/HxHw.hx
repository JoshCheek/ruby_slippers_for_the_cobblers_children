// the @:expose causes it to run 'var HxHw = exports.HxHw = ...`
// Note that you can also do `@:expose("whatever")`
// and then it will be `exports.whatever` instead of `exports.HxHw`
//
// problem right now is it figures out what exports is with:
//     `typeof window != "undefined" ? window : exports`
// Which means that my code, which uses it fine in node won't work in the browser
// I'm pretty sure this comes from here: https://github.com/HaxeFoundation/haxe/blob/a74040ecc0b567929dae231a5f0d20761baeb44a/genjs.ml#L1350
// I can't read that code very well, but it doesn't look like there's a way to override it.
//
// Current solution: use sed to remove it :/
// Maybe alternate solution: can I inline some js code that explicitly declares it on exports?
@:expose
class HxHw {
  public static function helloWorld()
    return "HAXE greets the world!";
}
