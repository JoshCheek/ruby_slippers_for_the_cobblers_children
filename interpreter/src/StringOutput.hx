class StringOutput extends haxe.io.Output {
  public var string:String;

  public function new(initialString="") {
    this.string = initialString;
  }

  public override function writeByte(c:Int):Void {
    string += String.fromCharCode(c);
  }

  public override function writeString(s:String):Void {
    string += s;
  }
}
