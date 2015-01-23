using StringTools;

class Inspect {
  public static function call(toInspect:Dynamic) {
    switch(Type.typeof(toInspect)) {
      case TBool:
        return inspectBool(toInspect);
      case TInt:
        return Std.string(toInspect);
      case TClass(klass): // Class<Dynamic>
        if(klass==String) return inspectString(toInspect);
        if(klass==Array)  return inspectArray(toInspect);
      case _:
        throw("No inspect available yet");
      // case TEnum(e): // Enum<Dynamic>
      // case TNull:
      // case TFloat:
      // case TBool:
      // case TObject:
      // case TFunction:
      // case TUnknown:
    }

    return "";
  }

  public static function inspectBool(toInspect:Bool)
    return Std.string(toInspect);

  public static function inspectString(toInspect:String) {
    return '"' +
           EscapeString.call(
             // do these go in EscapeString ?
             // or maybe EscapeString isn't really escaping so much as making all chars printable?
             toInspect.replace('\\', '\\\\')
                      .replace('"', '\\"')
          ) +
           '"';
  }

  public static function inspectArray(toInspect:Array<Dynamic>) {
    var inspectedElements = [];
    for(element in toInspect)
      inspectedElements.push(call(element));
    return "[" + inspectedElements.join(", ") + "]";
  }
}
