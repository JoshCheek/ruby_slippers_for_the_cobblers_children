package ruby3;

import ruby3.InternalMap;
import ruby3.Object;

typedef World = {
  // general state
  public var objectSpace       : Array<Object>;
  public var symbols           : InternalMap<Object>;
  public var toplevelNamespace : Object;
  public var printedToStdout   : Array<String>;

  // important objects -- prefixed with r b/c their names tend to collide w/ keywords
  public var rToplevelBinding  : Object;
  public var rMain             : Object;
  public var rNil              : Object;
  public var rTrue             : Object;
  public var rFalse            : Object;

  // important classes
  public var rcBasicObject     : Object; // should be RClass, but ADTs can't express this
  // Kernel goes here
  public var rcObject          : Object;
  public var rcModule          : Object;
  public var rcClass           : Object;
  public var rcString          : Object;
  public var rcSymbol          : Object;
}
