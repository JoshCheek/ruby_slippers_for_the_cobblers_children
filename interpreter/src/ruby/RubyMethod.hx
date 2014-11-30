package ruby;

class RubyMethod extends RubyObject {
  public var name : String;
  public var args : Array<RubyAst>;
  public var body : RubyAst;

  public function new(name:String, args:Array<RubyAst>, body:RubyAst) {
    super(new RubyClass("Method")); // FIXME
    this.name = name;
    this.args = args;
    this.body = body;
  }

  public function localsForArgs(args:Array<RubyObject>):haxe.ds.StringMap<RubyObject> {
    return new haxe.ds.StringMap();
  }
}
