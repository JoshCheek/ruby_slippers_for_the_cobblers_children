class Inspect {
  public static function call(toInspect:String) {
    return '"' +                           // open double quote
           StringTools.replace(
             EscapeString.call(toInspect), // escape each char
             '"',                          // replace double quote
             '\\"'                         // with escaped double quote (otherwise it would close the string)
           ) +
           '"';                            // close double quote
  }
}
