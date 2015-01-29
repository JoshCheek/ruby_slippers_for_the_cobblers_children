using StringTools;

/* Hmm. I can't use RTTI b/c the released version of Haxe is 3.1.3, from 2014-04-13
   But RTTI wasn't added until 2014-06-04 https://github.com/HaxeFoundation/haxe/commit/17650ee
   So I don't think there's any way to check to see if the obj is a subclass,
   or implements some interface or w/e. So, going to be a little iffy until then.
   But should suffice for most of my needs.
*/
class Inspect {
  // so you can say obj.inspect()
  public inline static function inspect(self:Dynamic) call(self);

  // so you can say Inspect.call(obj)
  public static function call(toInspect:Dynamic) {
    var inspected = itsInspectReturns(toInspect);
    if(inspected != null) return inspected;

    switch(Type.typeof(toInspect)) {
      case TFloat:
        return inspectFloat(toInspect);
      case TUnknown:
        return 'Unknown(${toInspect})';
      case TBool | TInt | TNull:
        return Std.string(toInspect);
      case TClass(klass): // Class<Dynamic>
        // might be useful: Type.getSuperClass(c:Class<Dynamic>):Class<Dynamic>
        if( klass==String) return inspectString(toInspect);
        if( klass==Array)  return inspectArray(toInspect);
        if( klass==List)   return inspectList(toInspect);
        if( haxe.ds.StringMap    == klass ||
            haxe.ds.IntMap       == klass ||
            haxe.ds.ObjectMap    == klass ||
            haxe.ds.EnumValueMap == klass
          ) return inspectMap(toInspect);
        throw 'No inspect for ${klass} yet!';
      case TObject:
        return inspectStruct(toInspect);
      case TFunction:
        // doesn't appear to be any way to get this info at present
        return "function(??) { ?? }";
      case TEnum(e):
        return inspectEnum(toInspect, e);
    }
  }

  private static function inspectFloat(toInspect:Float) {
    var inspected = Std.string(toInspect);
    if(~/\./.match(inspected)) return inspected;  // 12.34
    if(~/e/.match(inspected))  return inspected;  // 12.34e+50
    return inspected + ".0"; // 1 -> 1.0
  }

  private static function inspectString(toInspect:String) {
    return '"' +
           EscapeString.call(
             // do these go in EscapeString ?
             // or maybe EscapeString isn't really escaping so much as making all chars printable?
             toInspect.replace('\\', '\\\\')
                      .replace('"', '\\"')
          ) +
           '"';
  }

  private static function inspectArray(toInspect:Array<Dynamic>) {
    var inspectedElements = [];
    for(element in toInspect)
      inspectedElements.push(call(element));
    return "[" + inspectedElements.join(", ") + "]";
  }

  private static function inspectStruct(toInspect:Dynamic) {
    var keyValues = [];
    for(fieldName in Reflect.fields(toInspect)) {
      var inspectedValue = call(Reflect.field(toInspect, fieldName));
      keyValues.push('${fieldName}: ${inspectedValue}');
    }
    return "{" + keyValues.join(", ") + "}";
  }

  // Tried a lot of ways to reflect on this thing:
  //
  //   This works for structs, but not instances
  //     Reflect.fields(toInspect).indexOf("inspect");
  //   This works for instances, but not at runtime:
  //     Type.getClassFields(Type.getClass(toInspect));
  //
  // So, just try calling it.
  //
  //   Really, we shouldn't be catching all Strings, only ones that match "Invalid call"
  //   but I'll deal with that when it actually comes up, or when I've learned more about the language
  //   Maybe we can compile/install from HEAD and then have RTTI and ignore this altogether.
  private static function itsInspectReturns(toInspect:Dynamic) {
    try return toInspect.inspect()
    catch(_:String)  {}
    catch(_:Dynamic) {};
    return null;
  }

  private static function inspectMap(toInspect:Map.IMap<Dynamic,Dynamic>) {
    var keyValues = [];
    for(key in toInspect.keys())
      keyValues.push('${Inspect.call(key)} => ${Inspect.call(toInspect.get(key))}');
    return '[${keyValues.join(", ")}]';
  }

  private static function inspectEnum(instance:EnumValue, klass:Enum<Dynamic>) {
    var inspectedParams = [];
    for(param in Type.enumParameters(instance)) inspectedParams.push(call(param));
    var constructor = Type.enumConstructor(instance);
    if(inspectedParams.length == 0) return constructor;
    else return '$constructor(${inspectedParams.join(", ")})';
  }

  private static function inspectList(toInspect:List<Dynamic>) {
    var inspectedElements = [];
    for(element in toInspect)
      inspectedElements.push(call(element));
    return "(" + inspectedElements.join(", ") + ")";
  }
}
