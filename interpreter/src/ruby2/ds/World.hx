package ruby2.ds;
import ruby2.ds.Objects;

// The container of all state (actually, instructions are currently stored in the interpreter)
typedef World = {
  // interpreter
  public var currentExpression : RObject;
  public var stack             : List<Interpreter.StackFrame>;

  // general state
  public var objectSpace       : Array<RObject>;
  public var symbols           : InternalMap<RSymbol>;
  public var toplevelNamespace : RClass;
  public var printedToStdout   : Array<String>;

  // important objects
  public var toplevelBinding    : RBinding;
  public var main               : RObject;
  public var rubyNil            : RObject;
  public var rubyTrue           : RObject;
  public var rubyFalse          : RObject;

  // important classes
  public var objectClass        : RClass;
  public var basicObjectClass   : RClass;
  public var moduleClass        : RClass;
  public var klassClass         : RClass;
  public var stringClass        : RClass;
  public var symbolClass        : RClass;
}
