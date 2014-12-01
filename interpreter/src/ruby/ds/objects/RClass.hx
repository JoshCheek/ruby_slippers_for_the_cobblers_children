package ruby.ds.objects;

typedef RClass = {
  > RObject,
  name       : String,
  superclass : RClass,
  constants  : InternalMap<RObject>,
  imeths     : InternalMap<RMethod>,
}
