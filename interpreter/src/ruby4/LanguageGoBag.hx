package ruby4;

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

  public static function fromEnd<T>(iterable:Iterable<T>):List<T> {
    var reversed = new List<T>();
    for(element in iterable.iterator())
      reversed.push(element);
    return reversed;
  }
}
