// for reference: https://github.com/HaxeFoundation/haxe/blob/156f6241058dc065172da04f1fab1d89eaa22472/std/haxe/io/Output.hx
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

  public function inspect() {
    return '#<StringOutput string=${Inspect.call(string)}>';
  }
}
