using StringTools;

class Inspect {
  public static function call(toInspect:Dynamic) {
    switch(Type.typeof(toInspect)) {
      case TBool | TInt | TNull:
        return Std.string(toInspect);
      case TFloat:
        return inspectFloat(toInspect);
      case TClass(klass): // Class<Dynamic>
        if(klass==String) return inspectString(toInspect);
        if(klass==Array)  return inspectArray(toInspect);
      case _:
        throw("No inspect available yet");
      // case TEnum(e): // Enum<Dynamic>
      // case TObject:
      // case TFunction:
      // case TUnknown:
    }

    return "";
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
}
