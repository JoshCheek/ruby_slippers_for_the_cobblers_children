class RubyBinding extends RubyObject {
  public var self       : RubyObject;
  public var defTarget  : RubyClass;
  public var local_vars : Map<String, RubyObject>;

  public function new(args) {
    local_vars = new Map();
    self       = args.self;
    defTarget  = args.defTarget;
    super();
    withDefaults();
  }
}
