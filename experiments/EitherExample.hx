// apparently they removed Either from the language O.o
enum Either<L, R> {
  Left(v:L);
  Right(v:R);
}

typedef IorS = Either<Int, String>;

class EitherExample {
  public static function returnsLeft():IorS
    return Left(1);

  public static function returnsRight():IorS
    return Right("a");

  public static function printWhich(val:IorS)
    switch(val) {
      case Left(x):  trace("it was left: "  + Std.string(x));
      case Right(x): trace("it was right: " + Std.string(x));
    }

  public static function main() {
    printWhich(returnsLeft());
    printWhich(returnsRight());
  }
}
