package spaceCadet;

using StringTools;

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

  public var fgPop(  get, never) : Output;
  public var fgRed(  get, never):Output;
  public var fgGreen(get, never):Output;

  function get_fgPop() {
    colourStack.pop();
    if(null == colourStack.peek)
      write("\033[39m");
    else
      write(colourStack.peek);
    return this;
  }
  function get_fgRed() {
    var red = "\033[31m";
    colourStack.push(red);
    write(red);
    return this;
  }
  function get_fgGreen() {
    var green = "\033[32m";
    colourStack.push(green);
    write(green);
    return this;
  }
}

