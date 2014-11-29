package ruby;

class RubyBinding extends RubyObject {
  public var self      : RubyObject;
  public var defTarget : RubyClass;
  public var localVars : haxe.ds.StringMap<RubyObject>;

  public function new(self:RubyObject, defTarget:RubyClass) {
    this.localVars = new haxe.ds.StringMap();
    this.self      = self;
    this.defTarget = defTarget;
    super(new RubyClass('Binding')); // FIXME
  }
}
