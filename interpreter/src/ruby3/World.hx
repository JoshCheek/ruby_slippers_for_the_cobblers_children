package ruby3;

import ruby3.InternalMap;
import ruby3.Objects;


// For now, this will become a god class,
// as it evolves, pay attention to its responsibilities so we can extract them into their own objects.
class World {
  // general state
  public var objectSpace       : Array<RObject>;
  public var symbols           : InternalMap<RSymbol>;
  public var toplevelNamespace : RClass;
  public var printedToStdout   : Array<String>;

  // important objects -- prefixed with r b/c their names tend to collide w/ keywords
  public var rToplevelBinding  : RBinding;
  public var rMain             : RObject;
  public var rNil              : RObject;
  public var rTrue             : RObject;
  public var rFalse            : RObject;

  // important classes
  public var rcBasicObject     : RClass;
  // Kernel goes here
  public var rcObject          : RClass;
  public var rcModule          : RClass;
  public var rcClass           : RClass;
  public var rcString          : RClass;
  public var rcSymbol          : RClass;

  public static function bootstrap():World {
    return ruby3.Bootstrap.bootstrap();
  }

  public function new(?initializer:World->Void) {
    if(initializer != null) initializer(this);
  }

  public function eachObject(klass:RClass):Array<RObject> {
    var selected = [];
    for(obj in objectSpace)
      if(obj.klass == klass)
        selected.push(obj);
    return selected;
  }

  public function inspect():String {
    return 'RB(THE WORLD!!)';
  }

  // s b/c static and instance functions can't have the same name -.^
  static public function inspectObj(obj:RObject):String {
    if(obj == null) return 'Haxe null';

    var klass = switch(obj) {
      case {klass: k}: k;
      case _: throw "no kass here: " + obj;
    }

    if(klass.name == 'Class') {
      var tmp:Dynamic = obj;
      var objClass:RClass = tmp;
      return objClass.name;
    } else if(klass.name == 'String') {
      var tmp:Dynamic = obj;
      var objString:RString = tmp;
      return '"'+objString.value+'"'; // will do for now
    } else if(klass.name == 'Symbol') {
      var tmp:Dynamic = obj;
      var objSym:RSymbol = tmp;
      return ':'+objSym.name; // will do for now
    } else {
      // throw("NO INSPECTION FOR: " + obj.klass.name);
      return "#<" + obj.klass.name + ">";
    }
  }
}
