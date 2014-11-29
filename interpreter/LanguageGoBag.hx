class LanguageGoBag {
  public static function zip<A, B>(left:Iterable<A>, right:Iterable<B>):Iterable<{l: A, r: B}> {
    var zipped = new List();
    var as     = left.iterator();
    var bs     = right.iterator();

    while(as.hasNext() && bs.hasNext())
      zipped.add({l: as.next(), r: bs.next()});

    return zipped;
  }
}
