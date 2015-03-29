package ruby2;

// Using this instead of a typedef, b/c w/ the typedef,
// we lose the metainfo, and thus lose array access (bracket notation)
// the @:forward means that our abstract type has all the methods of the underlying type

@:forward
abstract InternalMap<T>(haxe.ds.StringMap<T>) {
  public function new() this = new haxe.ds.StringMap();

  @:arrayAccess public inline function get(k:String)      return this.get(k);
  @:arrayAccess public inline function set(k:String, v:T) return this.set(k, v);

  inline public function empty():Bool {
    return Lambda.empty(this);
  }
}
