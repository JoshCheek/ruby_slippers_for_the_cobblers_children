package ruby4;
using Inspect;

class RObject {
  public var klass:RClass;
  public var ivars:InternalMap<RObject>;

  public function new() {}
  public function inspect() {
    var klassname = null;
    try klass.inspect() catch(_:Dynamic) { } // -.-
    if(klass == null) klassname = 'Object without a klass!!';
    return 'RB(#<${klassname}>)';
  }
}

class RString extends RObject {
  public var value:String;
  override public function inspect() {
    return 'RB(#<String: ${value.inspect()}>)';
  }
}

class RSymbol extends RObject {
  public var name:String;
  override public function inspect() {
    return 'RB(<Symbol: :${name.inspect()}>)';
  }
}

class RClass extends RObject {
  public var name       : String;
  public var superclass : RClass;
  public var constants  : InternalMap<RObject>;
  public var imeths     : InternalMap<RMethod>;
  override public function inspect() {
    return 'RB(#<Class: ${EscapeString.call(name)}>)';
  }
}

class RBinding extends RObject {
  public var self      : RObject;
  public var defTarget : RClass;
  public var lvars     : InternalMap<RObject>;
  override public function inspect() {
    return 'RB(#<Binding for ${defTarget.inspect()}>)';
  }
}

enum ArgType {
  Required(name:String);
  Rest(name:String);
}
enum ExecutableType {
  // Ruby(ast:ExecutionState);
  // Internal(fn:RBinding -> ruby4.World -> EvaluationResult);
}
class RMethod extends RObject {
  public var name : String;
  public var args : Array<ArgType>; // rename to params
  public var body : ExecutableType;
  override public function inspect() {
    return 'RB(#<Method ${name.inspect()}(${args.inspect()})>)';
  }
}


class RArray extends RObject {
  public var elements : Array<RObject>;
  override public function inspect() {
    return 'RB(#<Array: ${elements.inspect()}>)';
  }
}
