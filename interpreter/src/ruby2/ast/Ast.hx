package ruby2.ast;

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

