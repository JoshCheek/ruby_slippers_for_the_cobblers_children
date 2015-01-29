package ruby;

typedef Location = {
  public var begin : Int;
  public var end   : Int;
}

typedef AstAttributes = { }
class Ast {
  public function new(?attributes:AstAttributes) {
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
  public function toValue()     : ValueAst     { throw("INVALID!"); return null; }
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

class OpenClassAst extends Ast {
  override public function get_isOpenClass() return true;
  override public function toOpenClass() return this;
}

class SendAst extends Ast {
  override public function get_isSend() return true;
  override public function toSend() return this;
}

class ValueAst extends Ast {
  override public function get_isValue() return true;
  override public function toValue() return this;
}

class DefAst extends Ast {
  override public function get_isDef() return true;
  override public function toDef() return this;
}


class Parse {
  public static var serverUrl = 'http://localhost:3003';

  public static function fromString(rawCode:String, ?serverUrl:String):Ast {
    if(serverUrl == null) serverUrl = Parse.serverUrl;
    var jsonString = ruby.Http.post(serverUrl, rawCode);
    var json       = haxe.Json.parse(jsonString);
    return fromJson(json);
  }

  static function fromJson(ast:Dynamic):Ast {
    if(ast == null) return new DefaultAst({});
    return switch(ast.type) {
      case "nil"                   : new NilAst();
      case "true"                  : new TrueAst();
      case "false"                 : new FalseAst();
      case "self"                  : new SelfAst();
      case "integer"               : new IntegerAst({value: Std.parseInt(ast.value)});
      case "float"                 : new FloatAst({value: Std.parseFloat(ast.value)});
      case "string"                : new StringAst({value: ast.value});
      case "expressions"           : new ExprsAst({expressions: ast.expressions.map(fromJson)});
      case "set_local_variable"    : new SetLvarAst({name: ast.name, value: fromJson(ast.value)});
      case "get_local_variable"    : new GetLvarAst({name: ast.name});
      case "set_instance_variable" : new SetIvarAst({name: ast.name, value: fromJson(ast.value)});
      case "get_instance_variable" : new GetIvarAst({name: ast.name});
      // case "send"                  : Send(Start(fromJson(ast.target), ast.message, ast.args.map(fromJson)));
      case "constant"              : new ConstAst({name: ast.name, ns: fromJson(ast.namespace)});
      // case "class"                 : OpenClass(GetNs(fromJson(ast.name_lookup), fromJson(ast.superclass), fromJson(ast.body)));
      // case "method_definition"     : Def(Start(ast.name, ast.args.map(toArg), fromJson(ast.body)));
      case _                       : throw("CAN'T PARSE: " + ast);
    }
  }

  // private static function toArg(arg:Dynamic):ArgType {
  //   switch(arg.type) {
  //     case "required_arg": return Required(arg.name);
  //     case "rest_arg":     return Rest(arg.name);
  //     case _: throw("Unknown arg type!: " + arg);
  //   }
  // }

  // private static function locationFrom(ast:Dynamic) {
  //   return {
  //     begin: ast.location.begin,
  //     end:   ast.location.end,
  //   };
  // }
}
