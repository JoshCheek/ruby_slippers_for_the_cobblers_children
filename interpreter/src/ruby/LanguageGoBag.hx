package ruby;

class LanguageGoBag {

  // it returns an iterable over the left and right iterables
  // where it hasNext while left and right both hasNext
  //
  // ...seems you can't pattern match like we hoped with
  //   for({l: name, r: email} in names.zip(emails).iterable())
  //
  // You have to do
  //   for(pair in names.zip(emails).iterable())
  //     doSomething(pair.l, pair.r);
  //
  // Which is strange, doesn't it seem like you should be able to
  // destructure on assignments (isn't this just a case of pattern matching?)
  public static function zip<A, B>(left:Iterable<A>, right:Iterable<B>):Iterable<{l: A, r: B}> {
    var zipped = new List();
    var as     = left.iterator();
    var bs     = right.iterator();

    while(as.hasNext() && bs.hasNext())
      zipped.add({l: as.next(), r: bs.next()});

    return zipped;
  }

  // I don't really get how to use this language well.
  // wouldn't it make more sense for the for/in to take
  // an iterable and call .iterable() on it?
  //
  // Then we could manipulate iterable objects, passing in to
  // the for/in at whatever point we want, with no implication
  // that we should be working directly with iterators.
  // Or Iterators should be iterable in that they could have
  //   public function iterator() return this;
  //
  // Maybe it would be possible to write these all with macros
  // such that we have the feel of Ruby iterators, which are
  // actually pretty fkn good, IMO, but with the performance
  // of inlining or w/e
  public static function reverseIterator<T>(iterable:Iterable<T>) {
    var reversed = new List<T>();
    for(element in iterable.iterator())
      reversed.push(element);
    return reversed.iterator();
  }

}
