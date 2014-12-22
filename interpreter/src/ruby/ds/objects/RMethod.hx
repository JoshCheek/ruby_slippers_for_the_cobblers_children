package ruby.ds.objects;

enum ExecutableType {
  Ruby(ast:Ast);
  Internal(fn:RBinding -> RObject);
}

typedef RMethod = {
  > RObject,
  name : String,
  args : Array<Ast>,
  body : ExecutableType,
}
