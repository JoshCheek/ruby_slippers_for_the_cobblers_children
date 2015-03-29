class EscapeString {
  // ASCII sequences only go up to 127,
  // and values above 127 are invalid UTF8... I think.
  // At the very least, \x80 is not a valid UTF8 byte.
  // So I'm just ignoring them for now.
  // Will figure out what I want to do if it comes up,
  // since I don't even know how Haxe handles encodings.
  public static function call(toEscape:String):String {
    var buffer = new StringBuf();
    var i = 0;
    while(i < toEscape.length) {
      var code = toEscape.charCodeAt(i);

      if((6 < code && code < 14) || code == 27)
        buffer.add(toEscapedChar(code));
      else if(code < 32 || code == 127)
        buffer.add(toHex(code));
      else
        // if performance is poor, an optimization would be to
        // look for runs of these and add them to the buffer in one go
        buffer.add(toEscape.charAt(i));

      i++;
    }
    return buffer.toString();
  }

  inline static function toHex(code:Int):String {
    return "\\x" + StringTools.hex(code, 2);
  }

  inline static function toEscapedChar(code:Int):String {
    switch(code) {
      case  7: return "\\a"; // bell
      case  8: return "\\b"; // backspace
      case  9: return "\\t"; // tab
      case 10: return "\\n"; // newline (linefeed)
      case 11: return "\\v"; // vertical tab
      case 12: return "\\f"; // form feed
      case 13: return "\\r"; // carriage return
      case 27: return "\\e"; // escape
      case  _: throw "WAT IS THIS THING: " + code;
    }
  }
}
