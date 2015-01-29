enum Letters {
  A;
  B;
  C(i:Int);
}
class EnumEquality {
  public static function main() {
    trace(A == A); // true
    trace(A == B); // false
    trace(B == A); // false

    // won't let me do this, b/c fuck ADTs
    // trace(C(1) == C(1));
    // trace(C(1) == C(2));
  }
}
