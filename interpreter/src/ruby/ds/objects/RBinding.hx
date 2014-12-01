package ruby.ds.objects;

class RBinding extends RObject {
  public var self      : RObject;
  public var defTarget : RClass;
  public var localVars : InternalMap<RObject>;

  // public function new(self:RObject, defTarget:RClass) {
  //   this.localVars = new InternalMap();
  //   this.self      = self;
  //   this.defTarget = defTarget;
  //   super(new RClass('Binding')); // FIXME
  // }
}
