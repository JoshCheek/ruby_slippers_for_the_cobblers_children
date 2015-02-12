package ruby4;

// Use "ref" to refer to the object, it'll be the object id in most cases
// this will facilitate immutabilty b/c it offers a layer of indirection:
// instead of pointing at that specific version of that object, it points
// to the id, which will still match.
//
// Calling it a ref instead of id, b/c if we add in Integers, we might use
// MRI's integer trick and not instantiate them.
//
// Technically these offer no type safety, I don't think, but it's more communicative.
typedef RObjectRef = Int;
typedef RClassRef  = Int;
typedef RMethodRef = Int;

typedef RObject = {
  var object_id : RObjectRef;
  var klass     : RClassRef;
  var ivars     : InternalMap<RObjectRef>;
}

typedef RString = {
  > RObject,
  var value:String;
}

typedef RSymbol = {
  > RObject,
  var name:String;
}

typedef RClass = {
  > RObject,
  var name       : String;
  var superclass : RClassRef;
  var constants  : InternalMap<RObjectRef>;
  var imeths     : InternalMap<RMethodRef>;
}

typedef RBinding = {
  > RObject,
  var self      : RObjectRef;
  var defTarget : RClassRef;
  var lvars     : InternalMap<RObjectRef>;
}

enum ArgType {
  Required(name:String);
  Rest(name:String);
}
enum ExecutableType {
  // Ruby(ast:ExecutionState);
  // Internal(fn:RBinding -> ruby4.World -> EvaluationResult);
}
typedef RMethod = {
  > RObject,
  var name : String;
  var args : Array<ArgType>; // rename to params
  var body : ExecutableType;
}

typedef RArray = {
  > RObject,
  var elements:Array<RObjectRef>;
}
