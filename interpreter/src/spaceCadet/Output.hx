package spaceCadet;

class Output {
  var outstream:haxe.io.Output;
  var errstream:haxe.io.Output;

  public function new(outstream, errstream) {
    this.outstream = outstream;
    this.errstream = errstream;
  }

  public function out(message) {
    this.outstream.writeString(message);
    this.outstream.writeString("\n");
    return this;
  }
}

