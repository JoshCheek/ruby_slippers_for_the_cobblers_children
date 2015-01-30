package ruby2;

typedef AstAttributes = {
  var begin_loc : Int;
  var end_loc   : Int;
}
class Ast {
  public var begin_loc : Int;
  public var end_loc   : Int;
  public function new(attributes:AstAttributes) {
    this.begin_loc = attributes.begin_loc;
    this.end_loc   = attributes.end_loc;
  }

  // emits a json-friendly inspection since it can be hard to
  // look at these things, and this way you can run it through jq
  public function inspect() {
    var klass     = Type.getClass(this);
    var inspected = '{"type": ${Inspect.call(Type.getClassName(klass))}';
    var fields    = Type.getInstanceFields(klass).filter(function(name) {
      return !~/^(is[A-Z]|to[A-Z]|get_|inspect)/.match(name);
    });

    for(name in fields) {
      var value = Reflect.getProperty(this, name);
      inspected += ', ${Inspect.call(name)}: ${Inspect.call(value)}';
    }

    return inspected + "}";
  }

  public var isDefault   (get, never) : Bool;
  public var isNil       (get, never) : Bool;
  public var isSelf      (get, never) : Bool;
  public var isTrue      (get, never) : Bool;
  public var isFalse     (get, never) : Bool;
  public var isInteger   (get, never) : Bool;
  public var isFloat     (get, never) : Bool;
  public var isString    (get, never) : Bool;
  public var isGetLvar   (get, never) : Bool;
  public var isSetLvar   (get, never) : Bool;
  public var isGetIvar   (get, never) : Bool;
  public var isSetIvar   (get, never) : Bool;
  public var isConst     (get, never) : Bool;
  public var isExprs     (get, never) : Bool;
  public var isOpenClass (get, never) : Bool;
  public var isSend      (get, never) : Bool;
  public var isValue     (get, never) : Bool;
  public var isDef       (get, never) : Bool;

  public function get_isDefault()   return false;
  public function get_isNil()       return false;
  public function get_isSelf()      return false;
  public function get_isTrue()      return false;
  public function get_isFalse()     return false;
  public function get_isInteger()   return false;
  public function get_isFloat()     return false;
  public function get_isString()    return false;
  public function get_isGetLvar()   return false;
  public function get_isSetLvar()   return false;
  public function get_isGetIvar()   return false;
  public function get_isSetIvar()   return false;
  public function get_isConst()     return false;
  public function get_isExprs()     return false;
  public function get_isOpenClass() return false;
  public function get_isSend()      return false;
  public function get_isValue()     return false;
  public function get_isDef()       return false;

  public function toDefault()   : DefaultAst   { throw("INVALID!"); return null; }
  public function toNil()       : NilAst       { throw("INVALID!"); return null; }
  public function toSelf()      : SelfAst      { throw("INVALID!"); return null; }
  public function toTrue()      : TrueAst      { throw("INVALID!"); return null; }
  public function toFalse()     : FalseAst     { throw("INVALID!"); return null; }
  public function toInteger()   : IntegerAst   { throw("INVALID!"); return null; }
  public function toFloat()     : FloatAst     { throw("INVALID!"); return null; }
  public function toString()    : StringAst    { throw("INVALID!"); return null; }
  public function toGetLvar()   : GetLvarAst   { throw("INVALID!"); return null; }
  public function toSetLvar()   : SetLvarAst   { throw("INVALID!"); return null; }
  public function toGetIvar()   : GetIvarAst   { throw("INVALID!"); return null; }
  public function toSetIvar()   : SetIvarAst   { throw("INVALID!"); return null; }
  public function toConst()     : ConstAst     { throw("INVALID!"); return null; }
  public function toExprs()     : ExprsAst     { throw("INVALID!"); return null; }
  public function toOpenClass() : OpenClassAst { throw("INVALID!"); return null; }
  public function toSend()      : SendAst      { throw("INVALID!"); return null; }
  public function toDef()       : DefAst       { throw("INVALID!"); return null; }
}

class DefaultAst extends Ast {
  override public function get_isDefault() return true;
  override public function toDefault() return this;
}

class NilAst extends Ast {
  override public function get_isNil() return true;
  override public function toNil() return this;
}

class SelfAst extends Ast {
  override public function get_isSelf() return true;
  override public function toSelf() return this;
}

class TrueAst extends Ast {
  override public function get_isTrue() return true;
  override public function toTrue() return this;
}

class FalseAst extends Ast {
  override public function get_isFalse() return true;
  override public function toFalse() return this;
}

typedef IntegerAstAttributes = {
  > AstAttributes,
  var value:Int;
}
class IntegerAst extends Ast {
  public var value:Int;
  public function new(attributes:IntegerAstAttributes) {
    this.value = attributes.value;
    super(attributes);
  }
  override public function get_isInteger() return true;
  override public function toInteger() return this;
}

typedef FloatAstAttributes = {
  > AstAttributes,
  var value:Float;
}
class FloatAst extends Ast {
  public var value:Float;
  public function new(attributes:FloatAstAttributes) {
    this.value = attributes.value;
    super(attributes);
  }
  override public function get_isFloat() return true;
  override public function toFloat() return this;
}

typedef StringAstAttributes = {
  > AstAttributes,
  var value:String;
}
class StringAst extends Ast {
  public var value:String;
  public function new(attributes:StringAstAttributes) {
    this.value = attributes.value;
    super(attributes);
  }
  override public function get_isString() return true;
  override public function toString() return this;
}

typedef GetLvarAstAttributes = {
  > AstAttributes,
  var name:String;
}
class GetLvarAst extends Ast {
  public var name:String;
  public function new(attributes:GetLvarAstAttributes) {
    this.name = attributes.name;
    super(attributes);
  }
  override public function get_isGetLvar() return true;
  override public function toGetLvar() return this;
}

typedef SetLvarAstAttributes = {
  > AstAttributes,
  var name  : String;
  var value : Ast;
}
class SetLvarAst extends Ast {
  public var name  : String;
  public var value : Ast;
  public function new(attributes:SetLvarAstAttributes) {
    this.name  = attributes.name;
    this.value = attributes.value;
    super(attributes);
  }
  override public function get_isSetLvar() return true;
  override public function toSetLvar() return this;
}

typedef GetIvarAstAttributes = {
  > AstAttributes,
  var name:String;
}
class GetIvarAst extends Ast {
  public var name:String;
  public function new(attributes:GetIvarAstAttributes) {
    this.name = attributes.name;
    super(attributes);
  }
  override public function get_isGetIvar() return true;
  override public function toGetIvar() return this;
}

typedef SetIvarAstAttributes = {
  > AstAttributes,
  var name  : String;
  var value : Ast;
}
class SetIvarAst extends Ast {
  public var name  : String;
  public var value : Ast;
  public function new(attributes:SetIvarAstAttributes) {
    this.name  = attributes.name;
    this.value = attributes.value;
    super(attributes);
  }
  override public function get_isSetIvar() return true;
  override public function toSetIvar() return this;
}

typedef ConstAstAttributes = {
  > AstAttributes,
  var name : String;
  var ns   : Ast;
}
class ConstAst extends Ast {
  public var name : String;
  public var ns   : Ast;
  public function new(attributes:ConstAstAttributes) {
    this.name = attributes.name;
    this.ns   = attributes.ns;
    super(attributes);
  }
  override public function get_isConst() return true;
  override public function toConst() return this;
}

typedef ExprsAstAttributes = {
  > AstAttributes,
  var expressions:Array<Ast>;
}
class ExprsAst extends Ast {
  var expressions : Array<Ast>;
  public function new(attributes:ExprsAstAttributes) {
    this.expressions = attributes.expressions;
    super(attributes);
  }
  override public function get_isExprs() return true;
  override public function toExprs() return this;

  public var length(get, never):Int;
  function get_length() return expressions.length;

  public function get(index:Int) {
    return expressions[index];
  }
}

typedef OpenClassAstAttributes = {
  > AstAttributes,
  var ns         : Ast;
  var superclass : Ast;
  var body       : Ast;
}
class OpenClassAst extends Ast {
  public var ns         : Ast;
  public var superclass : Ast;
  public var body       : Ast;
  public function new(attributes:OpenClassAstAttributes) {
    this.ns         = attributes.ns;
    this.superclass = attributes.superclass;
    this.body       = attributes.body;
    super(attributes);
  }
  override public function get_isOpenClass() return true;
  override public function toOpenClass() return this;
}

typedef SendAstAttributes = {
  > AstAttributes,
  var target    : Ast;
  var message   : String;
  var arguments : Array<Ast>;
}
class SendAst extends Ast {
  public var target    : Ast;
  public var message   : String;
  public var arguments : Array<Ast>;
  public function new(attributes:SendAstAttributes) {
    this.target    = attributes.target;
    this.message   = attributes.message;
    this.arguments = attributes.arguments;
    super(attributes);
  }
  override public function get_isSend() return true;
  override public function toSend() return this;
}


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
  > AstAttributes,
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


class Parse {
  public static var serverUrl = 'http://localhost:3003';

  public static function fromString(rawCode:String, ?serverUrl:String):Ast {
    if(serverUrl == null) serverUrl = Parse.serverUrl;
    var jsonString = ruby2.Http.post(serverUrl, rawCode);
    var json       = haxe.Json.parse(jsonString);
    return fromJson(json);
  }

  static function fromJson(ast:Dynamic):Ast {
    if(ast == null) return new DefaultAst({begin_loc: -1, end_loc: -1});
    return switch(ast.type) {
      case "nil"                   : new NilAst({begin_loc: begin_loc(ast), end_loc: end_loc(ast)});
      case "true"                  : new TrueAst({begin_loc: begin_loc(ast), end_loc: end_loc(ast)});
      case "false"                 : new FalseAst({begin_loc: begin_loc(ast), end_loc: end_loc(ast)});
      case "self"                  : new SelfAst({begin_loc: begin_loc(ast), end_loc: end_loc(ast)});
      case "integer"               : new IntegerAst({value: Std.parseInt(ast.value), begin_loc: begin_loc(ast), end_loc: end_loc(ast)});
      case "float"                 : new FloatAst({value: Std.parseFloat(ast.value), begin_loc: begin_loc(ast), end_loc: end_loc(ast)});
      case "string"                : new StringAst({value: ast.value, begin_loc: begin_loc(ast), end_loc: end_loc(ast)});
      case "expressions"           : new ExprsAst({expressions: ast.expressions.map(fromJson), begin_loc: begin_loc(ast), end_loc: end_loc(ast)});
      case "set_local_variable"    : new SetLvarAst({name: ast.name, value: fromJson(ast.value), begin_loc: begin_loc(ast), end_loc: end_loc(ast)});
      case "get_local_variable"    : new GetLvarAst({name: ast.name, begin_loc: begin_loc(ast), end_loc: end_loc(ast)});
      case "set_instance_variable" : new SetIvarAst({name: ast.name, value: fromJson(ast.value), begin_loc: begin_loc(ast), end_loc: end_loc(ast)});
      case "get_instance_variable" : new GetIvarAst({name: ast.name, begin_loc: begin_loc(ast), end_loc: end_loc(ast)});
      case "send"                  : new SendAst({target    : fromJson(ast.target),
                                                  message   : ast.message,
                                                  arguments : ast.args.map(fromJson),
                                                  begin_loc : begin_loc(ast),
                                                  end_loc   : end_loc(ast)});
      case "constant"              : new ConstAst({name: ast.name, ns: fromJson(ast.namespace), begin_loc: begin_loc(ast), end_loc: end_loc(ast)});
      case "class"                 : new OpenClassAst({ns         : fromJson(ast.name_lookup),
                                                       superclass : fromJson(ast.superclass),
                                                       body       : fromJson(ast.body),
                                                       begin_loc  : begin_loc(ast), end_loc: end_loc(ast)});
      case "method_definition"     : new DefAst({name:       ast.name,
                                                 parameters: ast.args.map(toParam),
                                                 body:       fromJson(ast.body),
                                                begin_loc: begin_loc(ast), end_loc: end_loc(ast)});
      case _                       : throw("CAN'T PARSE: " + ast);
    }
  }

  private static function toParam(param:Dynamic):Parameter {
    switch(param.type) {
      case "required_arg": return new Parameter(param.name, Required, begin_loc(param), end_loc(param));
      case "rest_arg":     return new Parameter(param.name, Rest, begin_loc(param), end_loc(param));
      case _: throw("Unknown arg type!: " + param);
    }
  }

  private static function begin_loc(ast:Dynamic) {
    return ast.location.begin;
  }
  private static function end_loc(ast:Dynamic) {
    return ast.location.end;
  }
}
