package ruby.ds.objects;

class RBinding extends RObject {
  public var self      : RObject;
  public var defTarget : RClass;
  public var localVars : haxe.ds.StringMap<RObject>;

  public function new(self:RObject, defTarget:RClass) {
    this.localVars = new haxe.ds.StringMap();
    this.self      = self;
    this.defTarget = defTarget;
    super(new RClass('Binding')); // FIXME
  }
}
