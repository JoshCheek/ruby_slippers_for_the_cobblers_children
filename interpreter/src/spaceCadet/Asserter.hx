package spaceCadet;

class Asserter {
  private var onSuccess : String -> haxe.PosInfos -> Void;
  private var onFailure : String -> haxe.PosInfos -> Void;
  private var onPending : String -> haxe.PosInfos -> Void;

  public function new(onSuccess, onFailure, onPending) {
    this.onSuccess = onSuccess;
    this.onFailure = onFailure;
    this.onPending = onPending;
  }

  public function eqm<T>(a:T, b:T, message, ?pos:haxe.PosInfos) {
    if(a == b) onSuccess(message, pos);
    else       onFailure(message, pos);
  }

  public function neqm<T>(a:T, b:T, message, ?pos:haxe.PosInfos) {
    if(a != b) onSuccess(message, pos);
    else       onFailure(message, pos);
  }

  public function eq<T>(a:T, b:T, ?pos:haxe.PosInfos) {
    var msg = Std.string(a) + " == " + Std.string(b);
    eqm(a, b, msg, pos);
  }

  public function neq<T>(a:T, b:T, ?pos:haxe.PosInfos) {
    var msg = Std.string(a) + " != " + Std.string(b);
    neqm(a, b, msg, pos);
  }

  public function streqm<T>(a:T, b:T, message, ?pos:haxe.PosInfos) {
    if(Std.string(a) == Std.string(b)) onSuccess(message, pos);
    else                               onFailure(message, pos);
  }

  public function nstreqm<T>(a:T, b:T, message, ?pos:haxe.PosInfos) {
    if(Std.string(a) != Std.string(b)) onSuccess(message, pos);
    else                               onFailure(message, pos);
  }

  public function streq<T>(a:T, b:T, ?pos:haxe.PosInfos) {
    var msg = "Std.string(" + Std.string(a) + ") == Std.string(" + Std.string(b) + ")";
    streqm(a, b, msg, pos);
  }

  public function nstreq<T>(a:T, b:T, ?pos:haxe.PosInfos) {
    var msg = "Std.string(" + Std.string(a) + ") != Std.string(" + Std.string(b) + ")";
    nstreqm(a, b, msg, pos);
  }

  public function pending(reason="Not Implemented", ?pos:haxe.PosInfos) {
    onPending(reason, pos);
  }
}
