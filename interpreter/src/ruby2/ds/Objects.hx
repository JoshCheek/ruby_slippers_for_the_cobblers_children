package ruby2.ds;
import ruby2.ds.Interpreter;
using Inspect;

class RObject {
  public var klass:RClass;
  public var ivars:InternalMap<RObject>;

  public function new() {}
  public function inspect() {
    return 'RB(#<${klass.inspect()}>)';
  }
}

class RString extends RObject {
  public var value:String;
  override public function inspect() {
    return 'RB(${value.inspect()})';
  }
}

class RSymbol extends RObject {
  public var name:String;
  override public function inspect() {
    return 'RB(:${name.inspect()})';
  }
}

class RClass extends RObject {
  public var name       : String;
  public var superclass : RClass;
  public var constants  : InternalMap<RObject>;
  public var imeths     : InternalMap<RMethod>;
  override public function inspect() {
    return 'RB(${EscapeString.call(name)})';
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
  Ruby(ast:ExecutionState);
  Internal(fn:RBinding -> ruby2.World -> EvaluationResult);
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
    return 'RB(${elements.inspect()})';
  }
}
