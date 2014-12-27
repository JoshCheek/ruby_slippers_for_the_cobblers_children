package ruby.ds;
import ruby.ds.Interpreter;

typedef RObject = {
  klass:RClass,
  ivars:InternalMap<RObject>,
}

typedef RString = {
  > RObject,
  value:String
}

typedef RSymbol = {
  > RObject,
  name:String
}

typedef RClass = {
  > RObject,
  name       : String,
  superclass : RClass,
  constants  : InternalMap<RObject>,
  imeths     : InternalMap<RMethod>,
}

typedef RBinding = {
  > RObject,
  self      : RObject,
  defTarget : RClass,
  lvars     : InternalMap<RObject>,
}

enum ArgType {
  Required(name:String);
  Rest(name:String);
}
enum ExecutableType {
  Ruby(ast:ExecutionState);
  Internal(fn:RBinding -> ruby.World -> EvaluationResult);
}
typedef RMethod = {
  > RObject,
  name : String,
  args : Array<ArgType>, // rename to params
  body : ExecutableType,
}


typedef RArray = {
  > RObject,
  elements : Array<RObject>,
}
