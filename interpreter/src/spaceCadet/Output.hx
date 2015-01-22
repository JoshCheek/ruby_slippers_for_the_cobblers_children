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
  var indentDepth = 0;
  var indentNext  = true;
  var writeColour = false;

  public function new(outstream, errstream) {
    this.outstream   = outstream;
    this.errstream   = errstream;
    this.colourStack = new Stack();
  }

  public function writeln(message:String) {
    if(!message.endsWith("\n")) message += "\n";
    write(message);
    indentNext = true;
    return this;
  }

  public function write(message:String) {
    if(writeColour) {
      writeColour = false;
      if(colourStack.isEmpty) message = Colour.FgNone    + message;
      else                    message = colourStack.peek + message;
    }
    if(indentNext) {
      indentNext = false;
      var i = 0;
      while(i++ < indentDepth) message = "  " + message;
    }
    outstream.writeString(message);
    outstream.flush();
    return this;
  }

  public var resetln(get, never):Output;
  public function get_resetln() {
    write("\r\033[2K");
    indentNext = true;
    return this;
  }

  public function yield(fn:Void->Void) {
    fn();
    return this;
  }

  public var indent(get, never):Output;
  public function get_indent() {
    indentDepth++;
    return this;
  }

  public var outdent(get, never):Output;
  public function get_outdent() {
    if(indentDepth == 0) throw "Cannot outdent, there is no indentation!";
    indentDepth--;
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
    colourStack.push(colour);
    writeColour = true;
    return this;
  }
  function get_fgPop() {
    if(colourStack.isEmpty) throw "Colour stack is empty, nothing to pop!";
    colourStack.pop();
    writeColour = true;
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

