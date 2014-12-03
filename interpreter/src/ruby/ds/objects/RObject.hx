package ruby.ds.objects;

typedef RObject = {
  klass    : RClass,
  ivars    : InternalMap<RObject>,
  // toString : Void -> String,
}
