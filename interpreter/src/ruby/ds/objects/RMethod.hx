package ruby.ds.objects;

class RMethod extends RObject {
  public var name : String;
  public var args : Array<Ast>;
  public var body : Ast;

  // public function new(name:String, args:Array<Ast>, body:Ast) {
  //   super(new RClass("Method")); // FIXME
  //   this.name = name;
  //   this.args = args;
  //   this.body = body;
  // }

  public function localsForArgs(args:Array<RObject>):InternalMap<RObject> {
    return new InternalMap();
  }
}
