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
    var msg = Inspect.call(a) + " == " + Inspect.call(b);
    eqm(a, b, msg, pos);
  }

  public function neq<T>(a:T, b:T, ?pos:haxe.PosInfos) {
    var msg = Inspect.call(a) + " != " + Inspect.call(b);
    neqm(a, b, msg, pos);
  }

  public function streqm<T>(a:T, b:T, message, ?pos:haxe.PosInfos) {
    if(Inspect.call(a) == Inspect.call(b)) onSuccess(message, pos);
    else                                   onFailure(message, pos);
  }

  public function nstreqm<T>(a:T, b:T, message, ?pos:haxe.PosInfos) {
    if(Inspect.call(a) != Inspect.call(b)) onSuccess(message, pos);
    else                                   onFailure(message, pos);
  }

  public function streq<T>(a:T, b:T, ?pos:haxe.PosInfos) {
    var msg = '${Inspect.call(a)}.inspect() == ${Inspect.call(b)}.inspect()';
    streqm(a, b, msg, pos);
  }

  public function nstreq<T>(a:T, b:T, ?pos:haxe.PosInfos) {
    var msg = '${Inspect.call(a)}.inspect() == ${Inspect.call(b)}.inspect()';
    nstreqm(a, b, msg, pos);
  }

  public function t(val:Bool, ?pos:haxe.PosInfos) {
    var msg = 'Should have been true';
    tm(val, msg, pos);
  }

  public function tm(val:Bool, msg:String, ?pos:haxe.PosInfos) {
    eqm(true, val, msg, pos);
  }

  public function f(val:Bool, ?pos:haxe.PosInfos) {
    var msg = 'Should have been false';
    fm(val, msg, pos);
  }

  public function fm(val:Bool, msg:String, ?pos:haxe.PosInfos) {
    eqm(false, val, msg, pos);
  }

  public function pending(reason="Not Implemented", ?pos:haxe.PosInfos) {
    onPending(reason, pos);
  }
}
