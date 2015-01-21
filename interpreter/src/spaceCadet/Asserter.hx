package spaceCadet;

class Asserter {
  private var onSuccess : String -> Void;
  private var onFailure : String -> Void;
  private var onPending : String -> Void;

  public function new(onSuccess, onFailure, onPending) {
    this.onSuccess = onSuccess;
    this.onFailure = onFailure;
    this.onPending = onPending;
  }

  public function eqm<T>(a:T, b:T, message) {
    if(a == b) onSuccess(message);
    else       onFailure(message);
  }

  public function neqm<T>(a:T, b:T, message) {
    if(a != b) onSuccess(message);
    else       onFailure(message);
  }

  public function eq<T>(a:T, b:T) {
    var msg = Std.string(a) + " == " + Std.string(b);
    eqm(a, b, msg);
  }
  public function neq<T>(a:T, b:T) {
    var msg = Std.string(a) + " != " + Std.string(b);
    neqm(a, b, msg);
  }

  public function streqm<T>(a:T, b:T, message) {
    if(Std.string(a) == Std.string(b)) onSuccess(message);
    else                               onFailure(message);
  }

  public function nstreqm<T>(a:T, b:T, message) {
    if(Std.string(a) != Std.string(b)) onSuccess(message);
    else                               onFailure(message);
  }

  public function streq<T>(a:T, b:T) {
    var msg = "Std.string(" + Std.string(a) + ") == Std.string(" + Std.string(b) + ")";
    streqm(a, b, msg);
  }

  public function nstreq<T>(a:T, b:T) {
    var msg = "Std.string(" + Std.string(a) + ") != Std.string(" + Std.string(b) + ")";
    nstreqm(a, b, msg);
  }

  public function pending(reason="Not Implemented") {
    onPending(reason);
  }
}
