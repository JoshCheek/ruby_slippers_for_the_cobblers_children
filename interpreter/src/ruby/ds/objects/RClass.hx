package ruby.ds.objects;

typedef RClass {
  > RObject,
  name       : String;
  constants  : InternalMap<RObject>;
  imeths     : InternalMap<RMethod>;
  superclass : RClass;
}
