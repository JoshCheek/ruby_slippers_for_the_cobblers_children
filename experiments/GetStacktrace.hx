class GetStacktrace {
  static function ca() return cb();
  static function cb() return cc();
  static function cc() return haxe.CallStack.callStack();

  static function ea() eb();
  static function eb() ec();
  static function ec() throw "THIS IS THE THROWN STRING";

  public static function main() {
    trace("Callstack:");
    for(idk in ca()) trace(idk);
    trace("");

    trace("Exception Callstack:");
    try ea()
    catch(msg:String) {
      trace(msg);
      var stack = haxe.CallStack.exceptionStack();
      trace(haxe.CallStack.toString(stack));
    }
  }
}
