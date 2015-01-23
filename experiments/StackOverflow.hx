class StackOverflow {
  public static function recurse() recurse();
  public static function main() {
    try {
      recurse();
    } catch(e:String) {
      trace(e);
      trace(e == "Stack Overflow");
    }
  }
}
