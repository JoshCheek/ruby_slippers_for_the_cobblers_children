package spaceCadet;

class Output {
  var outstream:haxe.io.Output;
  var errstream:haxe.io.Output;

  public function new(outstream, errstream) {
    this.outstream = outstream;
    this.errstream = errstream;
  }

  public function writeln(message) {
    outstream.writeString(message);
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
}

