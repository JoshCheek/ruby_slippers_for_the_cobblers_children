package ruby.ds.objects;

typedef RBinding = {
  > RObject,
  self      : RObject,
  defTarget : RClass,
  lvars     : InternalMap<RObject>,
}
