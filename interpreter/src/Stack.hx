@:forward(length, pop)
abstract Stack<T>(List<T>) {
  public var peek(get, never):T;
  public var isEmpty(get, never):Bool;

  public function new() {
    this = new List<T>();
  }

  inline public function push(datum:T):T {
    this.push(datum);
    return datum;
  }

  // private
  inline function get_peek()    return this.first();
  inline function get_isEmpty() return this.isEmpty();
}
