// http://haxe.org/manual/lf-pattern-matching.html

enum Reduction<A, B> {
  InProgress(memo:B, rest:Array<A>, fn:B->A->B);
  Finished(result:B);
}


class Reducer {
  // pattern matching only works on arrays of a fixed length :/
  public static function reduce<A, B>(reduction:Reduction<A, B>) {
    return switch(reduction) {
      case InProgress(result, [], _):  reduce(Finished(result));
      case InProgress(memo, rest, fn): reduce(InProgress(fn(memo, rest.shift()), rest, fn));
      case Finished(result):           result;
    }
  }
}

class PatternMatching {
  public static function main() {
    var reduction = InProgress(0, [1,5,6], function(sum, n) return sum + n);
    trace(Reducer.reduce(reduction));

    var reduction = InProgress(0, ["abc", "d", "ef"], function(sum, word) return sum + word.length);
    trace(Reducer.reduce(reduction));
  }
}
