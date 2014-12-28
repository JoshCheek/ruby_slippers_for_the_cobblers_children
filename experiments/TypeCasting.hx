typedef DsObject = { objectStuff:String }
typedef DsString = { > DsObject, stringStuff:String }
typedef DsSymbol = { > DsObject, symbolStuff:String }

class RObject {
  public var obj:DsObject;
  public function new(obj:DsObject) this.obj = obj;
  public function toString():String return "#<RObject: " + obj + ">";
}

class RString extends RObject {
  public var strObj:DsString;
  public function new(obj:DsString) super(this.strObj = obj);
  override public function toString():String return '#<RString:"' + strObj.stringStuff + '">';
}

class RSymbol extends RObject {
  public var symObj:DsSymbol;
  public function new(obj:DsSymbol) super(this.symObj = obj);
  override public function toString():String return '#<RSymbol:"' + symObj.symbolStuff + '">';
}

class TypeCasting {
  public static function rCast<T>(robj:RObject, subklass:Class<T>):T {
    return cast(robj); // Can't figure out how to assert that robj *really is* an instance of subklass :(
  }

  public static function main() {
    var initialStr = new RString({objectStuff:"object-stuff-1", stringStuff:"STR-stuff"});
    var initialSym = new RSymbol({objectStuff:"object-stuff-2", symbolStuff:"SYM-stuff"});
    trace("-----");
    trace(initialStr);
    trace(initialSym);

    var strThroughObject:RObject = initialStr;
    var symThroughObject:RObject = initialSym;
    trace("-----");
    trace(strThroughObject);
    trace(symThroughObject);

    var backToStr = rCast(strThroughObject, RString);
    var backToSym = rCast(symThroughObject, RSymbol);
    trace("-----");
    trace(strThroughObject);
    trace(symThroughObject);

    // Fails b/c cast it to RString, but expect a RSymbol
    // var backToStr:RSymbol = rCast(strThroughObject, RString);
  }
}
