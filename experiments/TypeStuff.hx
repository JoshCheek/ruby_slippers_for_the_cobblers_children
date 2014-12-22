// Failed experiment >.<

// Idris has an interesting example of building up compiletime types:
// curl https://gist.githubusercontent.com/puffnfresh/11202637/raw/033723bab0b31ffadf40c5c3e340701849ae13cc/Printf.idr > Printf.idr

enum Z {}
enum S<A>{}
// typedef Y = S<Z>;

enum NumList<T> {
  Node(x:Int, rest:NumList<T>):NumList<S<T>>;
  EOL:NumList<T>;
}


class TypeStuff {
  public static function mkNode<T>(a:Int, b:NumList<T>):NumList<S<T>> {
    return Node(a, b);
  }

  public static function mkEnd():NumList<Z> {
    return EOL;
  }

  public static function count<T>(a:NumList<S<T>>):Int {
    switch(a) {
      // case Node(crnt, EOL):  return 1;
      case Node(crnt, rest): return 1 ;//+ count(rest);
    }
    return 1;
  }

  public static function main() {
    var last:NumList<Z>      = mkEnd();
    var one:NumList<S<Z>>    = mkNode(1, last);
    var two:NumList<S<S<Z>>> = mkNode(1, one);
    trace(count(two));
    // count(mkNode(2, mkNode(1, mkEnd())));
  }
}

