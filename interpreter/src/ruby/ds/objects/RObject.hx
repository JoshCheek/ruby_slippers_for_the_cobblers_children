package ruby.ds.objects;

typedef RObject = {
  klass : RClass,
  ivars : InternalMap<RObject>,
}
