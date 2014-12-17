class ShellingOut {
  public static function ls(option:String):Array<String> {
    var process = new sys.io.Process('ls', [option]);
    var result  = [];
    try { while(true) result.push(process.stdout.readLine()); }
    catch (ex:haxe.io.Eof) { /* no op */ }
    return result;
  }

  public static function main() {
    for(line in ls('-l'))
      trace(line);
  }
}
