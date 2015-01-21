package spaceCadet;

using StringTools;

@:enum
abstract Colour(String) from String to String {
  var FgNone    = "\033[39m";
  var FgBlack   = "\033[30m";
  var FgRed     = "\033[31m";
  var FgGreen   = "\033[32m";
  var FgYellow  = "\033[33m";
  var FgBlue    = "\033[34m";
  var FgMagenta = "\033[35m";
  var FgCyan    = "\033[36m";
  var FgWhite   = "\033[37m";
}

class Output {
  var outstream   : haxe.io.Output;
  var errstream   : haxe.io.Output;
  var colourStack : Stack<String>;

  public function new(outstream, errstream) {
    this.outstream   = outstream;
    this.errstream   = errstream;
    this.colourStack = new Stack();
  }

  public function writeln(message) {
    outstream.writeString(message);
    if(!message.endsWith("\n"))
      outstream.writeString("\n");
    return this;
  }

  public function write(message) {
    outstream.writeString(message);
    return this;
  }

  public function replaceln(message) {
    outstream.writeString("\r");
    outstream.writeString(message);
    return this;
  }

  public var fgPop     (get, never):Output;
  public var fgBlack   (get, never):Output;
  public var fgRed     (get, never):Output;
  public var fgGreen   (get, never):Output;
  public var fgYellow  (get, never):Output;
  public var fgBlue    (get, never):Output;
  public var fgMagenta (get, never):Output;
  public var fgCyan    (get, never):Output;
  public var fgWhite   (get, never):Output;

  function pushColour(colour:Colour) {
    write(colourStack.push(colour));
    return this;
  }
  function get_fgPop() {
    if(colourStack.pop() == null) throw "Colour stack is empty, nothing to pop!";
    if(null == colourStack.peek)  write(Colour.FgNone);
    else                          write(colourStack.peek);
    return this;
  }
  function get_fgBlack()   return pushColour(FgBlack);
  function get_fgRed()     return pushColour(FgRed);
  function get_fgGreen()   return pushColour(FgGreen);
  function get_fgYellow()  return pushColour(FgYellow);
  function get_fgBlue()    return pushColour(FgBlue);
  function get_fgMagenta() return pushColour(FgMagenta);
  function get_fgCyan()    return pushColour(FgCyan);
  function get_fgWhite()   return pushColour(FgWhite);
}

