package ruby.ds;

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

enum ExecutableType {
  Ruby(ast:Ast);
  Internal(fn:RBinding -> ruby.World -> RObject);
}
typedef RMethod = {
  > RObject,
  name : String,
  args : Array<Ast>,
  body : ExecutableType,
}

