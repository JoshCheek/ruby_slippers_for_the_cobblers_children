package ruby4.ast;

enum ParameterType {
  Required;
  Rest;
}

class Parameter {
  public var name      : String;
  public var type      : ParameterType;
  public var begin_loc : Int;
  public var end_loc   : Int;
  public function new(name:String, type:ParameterType, begin_loc:Int, end_loc:Int) {
    this.name      = name;
    this.type      = type;
    this.begin_loc = begin_loc;
    this.end_loc   = end_loc;
  }
}

typedef DefAstAttributes = {
  > Ast.AstAttributes,
  var name       : String;
  var parameters : Array<Parameter>;
  var body       : Ast;
}

class DefAst extends Ast {
  public var name       : String;
  public var parameters : Array<Parameter>;
  public var body       : Ast;
  public function new(attributes:DefAstAttributes) {
    this.name       = attributes.name;
    this.parameters = attributes.parameters;
    this.body       = attributes.body;
    super(attributes);
  }
  override public function get_isDef() return true;
  override public function toDef() return this;
}
