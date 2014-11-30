package ruby;

class RubyMethod extends RubyObject {
  public var name : String;
  public var args : Array<Ast>;
  public var body : Ast;

  public function new(name:String, args:Array<Ast>, body:Ast) {
    super(new RubyClass("Method")); // FIXME
    this.name = name;
    this.args = args;
    this.body = body;
  }

  public function localsForArgs(args:Array<RubyObject>):haxe.ds.StringMap<RubyObject> {
    return new haxe.ds.StringMap();
  }
}
