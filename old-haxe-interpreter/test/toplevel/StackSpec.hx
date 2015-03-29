package toplevel;

class StackSpec {
  public static function describe(d:spaceCadet.Description) {
    d.it('does stack things...', function(a) {
      var s = new Stack<String>();
      a.eq(0,     s.length);
      a.eq(null,  s.peek);
      a.eq(true,  s.isEmpty);

      a.eq("a",   s.push("a"));
      a.eq(1,     s.length);
      a.eq("a",   s.peek);
      a.eq(false, s.isEmpty);

      s.push("c");
      a.eq(2,     s.length);
      a.eq("c",   s.peek);
      a.eq(false, s.isEmpty);

      a.eq("c",   s.pop());
      a.eq(1,     s.length);
      a.eq("a",   s.peek);
      a.eq(false, s.isEmpty);

      a.eq("x",   s.push("x"));
      a.eq("y",   s.push("y"));
      a.eq("z",   s.push("z"));
      a.eq(4,     s.length);

      a.eq("z",   s.pop());
      a.eq("y",   s.pop());
      a.eq("x",   s.pop());
      a.eq(1,     s.length);

      a.eq("a",   s.pop());
      a.eq(0,     s.length);
      a.eq(null,  s.peek);
      a.eq(true,  s.isEmpty);
    });
  }
}
