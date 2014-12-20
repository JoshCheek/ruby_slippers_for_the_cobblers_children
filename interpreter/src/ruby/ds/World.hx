package ruby.ds;
import ruby.ds.objects.*;

// The container of all state (actually, instructions are currently stored in the interpreter)
typedef World = {
  public var stack              : Array<RBinding>;
  public var objectSpace        : Array<RObject>;
  public var symbols            : InternalMap<RSymbol>;
  public var currentExpression  : RObject;
  public var toplevelNamespace  : RClass;
  public var toplevelBinding    : RBinding;
  public var main               : RObject;
  public var rubyNil            : RObject;
  public var rubyTrue           : RObject;
  public var rubyFalse          : RObject;
  public var klassClass         : RClass;
  public var objectClass        : RClass;
}
