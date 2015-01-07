package ruby.ds;
import ruby.ds.Interpreter;

class RObject {
  public var klass:RClass;
  public var ivars:InternalMap<RObject>;

  public function new() {}
}

class RString extends RObject {
  public var value:String;
}

class RSymbol extends RObject {
  public var name:String;
}

class RClass extends RObject {
  public var name       : String;
  public var superclass : RClass;
  public var constants  : InternalMap<RObject>;
  public var imeths     : InternalMap<RMethod>;
}

class RBinding extends RObject {
  public var self      : RObject;
  public var defTarget : RClass;
  public var lvars     : InternalMap<RObject>;
}

enum ArgType {
  Required(name:String);
  Rest(name:String);
}
enum ExecutableType {
  Ruby(ast:ExecutionState);
  Internal(fn:RBinding -> ruby.World -> EvaluationResult);
}
class RMethod extends RObject {
  public var name : String;
  public var args : Array<ArgType>; // rename to params
  public var body : ExecutableType;
}


class RArray extends RObject {
  public var elements : Array<RObject>;
}
