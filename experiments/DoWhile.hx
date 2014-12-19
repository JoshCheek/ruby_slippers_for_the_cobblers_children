class DoWhile {
  public static function main() {
    var i = 0;
    do ++i while(i<0); // check runs after block
    trace(i);
  }
}
