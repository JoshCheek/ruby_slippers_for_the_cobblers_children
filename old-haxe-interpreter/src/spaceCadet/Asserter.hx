package spaceCadet;

class Asserter {
  private var onSuccess : String -> haxe.PosInfos -> Void;
  private var onFailure : String -> haxe.PosInfos -> Void;
  private var onPending : String -> haxe.PosInfos -> Void;
  public  var p         : Printer; // so specs can output with colour and indentation

  public function new(onSuccess, onFailure, onPending, printer) {
    this.onSuccess = onSuccess;
    this.onFailure = onFailure;
    this.onPending = onPending;
    this.p         = printer;
  }

  public function d(?typeOrMessage:Printer.StringOrDynamic, ?message:Printer.StringOrDynamic):Printer {
    return p.d(typeOrMessage, message);
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
    var msg = 'Expected ${Inspect.call(a)} == ${Inspect.call(b)}';
    eqm(a, b, msg, pos);
  }

  public function neq<T>(a:T, b:T, ?pos:haxe.PosInfos) {
    var msg = 'Expected: ${Inspect.call(a)} != ${Inspect.call(b)}';
    neqm(a, b, msg, pos);
  }

  public function streqm<T>(a:T, b:T, message, ?pos:haxe.PosInfos) {
    eqm(Inspect.call(a), Inspect.call(b), message, pos);
  }

  public function nstreqm<T>(a:T, b:T, message, ?pos:haxe.PosInfos) {
    neqm(Inspect.call(a), Inspect.call(b), message, pos);
  }

  public function streq<T>(a:T, b:T, ?pos:haxe.PosInfos) {
    var msg = '${Inspect.call(a)}.inspect() == ${Inspect.call(b)}.inspect()';
    streqm(a, b, msg, pos);
  }

  public function nstreq<T>(a:T, b:T, ?pos:haxe.PosInfos) {
    var msg = '${Inspect.call(a)}.inspect() == ${Inspect.call(b)}.inspect()';
    nstreqm(a, b, msg, pos);
  }

  public function isTrue(val:Bool, ?pos:haxe.PosInfos) {
    isTruem(val, 'Should have been true', pos);
  }

  public function isTruem(val:Bool, msg:String, ?pos:haxe.PosInfos) {
    eqm(true, val, msg, pos);
  }

  public function isFalse(val:Bool, ?pos:haxe.PosInfos) {
    isFalsem(val, 'Should have been false', pos);
  }

  public function isFalsem(val:Bool, msg:String, ?pos:haxe.PosInfos) {
    eqm(false, val, msg, pos);
  }

  public function pending(reason="Not Implemented", ?pos:haxe.PosInfos) {
    onPending(reason, pos);
  }
}
