// @:native("module") means that when we say `NodeModule.exports = ...`
// the compiled code will be `module.exports`
//
// extern means that rather than generating this, it will expect the environment to define it
// in our case, node.js or browserify will define it
//
// Found these by playing with the metadata that seemed potentially relevant at https://github.com/HaxeFoundation/haxe/blob/b84ca37d1d5ebc0c7af9a3c0c8408d4f9b853879/common.ml#L324-474
// ruby -ne 'print $., gsub(/^\W*(\w+)/) { "\e[32m %-20s\e[0m" % $1 } if (345..474).cover? $. and (!/\bPlatforms?\b/ || /\bJs\b/)' common.ml
@:native("module") extern class NodeModule {
  public static var exports:Dynamic;
}

class HxHw {
  public static function helloWorld() return "HAXE greets the world!";
  public static function main()       NodeModule.exports = HxHw;
}
