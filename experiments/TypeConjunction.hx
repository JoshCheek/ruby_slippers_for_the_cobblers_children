enum NeedleValue {
  Str(v:String);
  Reg(v:EReg);
}

// I so don't get these abstract classes
abstract Needle(NeedleValue) {
  public function new(needle) {
    this = needle;
  }
  @:from
  static public function fromString(s) {
    return new Needle(Str(s));
  }
  @:from
  static public function fromRegex(r) {
    return new Needle(Reg(r));
  }
  @:to
  public function val():NeedleValue {
    return this;
  }
}

class Haystack {
  var haystack:String;

  public function new(haystack:String) {
    this.haystack = haystack;
  }

  public function matchType(needle:Needle) {
    // Have to cal .val(), b/c it can't match them up
    // Maybe with a macro, you could intercept callers
    // and if they're passing a string, then you could
    // escape it yourself and then turn it into a regex.
    // or escape both regexes and strings, and turn them into
    // a custom regex class.
    //
    // Then again, my attempts at making macros have all failed,
    // so I'm not sure I'm capable of achieving this without a lot more experience.
    //
    // But then again, it's not actually clear ot me that
    // regex can do all the things I'd want to do (need to play w/ the API a bit)
    // and there's no way to extract the data back out of it
    // it doesn't even inspect right when you do Std.string
    // and the Neko version, at least, has marked itself "@:final"
    // https://github.com/HaxeFoundation/haxe/blob/75b42ae10125a56650c56786c8946ca97fc638b6/std/neko/_std/EReg.hx#L22
    // which probably means I couldn't do something like subclass it
    // in order to record the params it was constructed with so that I could build my own
    switch(needle.val()) {
      case Str(s): return 'NEEDLE IS A STRING: ${s}';
      case Reg(r): return 'NEEDLE IS A EREG:   ${r}';
    }
  }
}

class TypeConjunction {
  public static function main() {
    trace("should be string: " + new Haystack("abcdefg").matchType("c"));
    trace("should be regex: " + new Haystack("abcdefg").matchType(~/c/));
    // trace("String matching (should be 2): " + matchIndex("abcdefg", "c"));
  }
}
