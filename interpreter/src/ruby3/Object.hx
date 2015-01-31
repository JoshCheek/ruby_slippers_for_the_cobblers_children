package ruby3;

// ADTs can't grasp the concept that it is allowed to reference one of the values
// so I have to put Object everywhere
enum Object {
  RObject(
    klass : Object, // should be RClass
    ivars : InternalMap<Object>
  );

  RString(
    klass : Object, // should be RClass
    ivars : InternalMap<Object>,
    value : String
  );

  RSymbol(
    klass : Object, // should be RClass
    ivars : InternalMap<Object>,
    name  : String
  );

  RClass(
    klass      : Object,              // should be RClass
    ivars      : InternalMap<Object>,
    name       : String,
    superclass : Object,              // should be RClass
    constants  : InternalMap<Object>,
    imeths     : InternalMap<Object>  // should be RMeth
  );

  RBinding(
    klass     : Object, // should be RClass
    self      : Object,
    defTarget : Object, // should be RClass (and eventually either RClass or RModule)
    lvars     : InternalMap<Object>
  );

  RMethod(
    klass  : Object,  // should be RClass
    ivars  : InternalMap<Object>,
    name   : String,
    params : Array<ParamType>,
    body   : ExecutableType
  );

  RArray(
    klass    : Object, // should be RClas
    ivars    : InternalMap<Object>,
    elements : Array<Object>
  );
}

enum ParamType {
  Required(name:String);
  Rest(name:String);
}
enum ExecutableType {
  // Ruby(ast:ExecutionState);
  // Internal(fn:RBinding -> ruby3.World -> EvaluationResult);
}
