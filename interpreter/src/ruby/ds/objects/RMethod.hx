package ruby.ds.objects;

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
