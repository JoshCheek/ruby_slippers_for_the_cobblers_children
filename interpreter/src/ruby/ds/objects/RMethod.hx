package ruby.ds.objects;

typedef RMethod = {
  > RObject,
  name : String,
  args : Array<Ast>,
  body : Ast,
}
