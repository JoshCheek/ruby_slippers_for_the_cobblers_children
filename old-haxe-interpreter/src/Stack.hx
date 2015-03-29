abstract Stack<T>(List<T>) {

  public function new()
    this = new List<T>();

  public var peek    (get, never):T;
  public var isEmpty (get, never):Bool;
  public var length  (get, never):Int;

  inline public function push(datum:T):T {
    this.push(datum);
    return datum;
  }

  inline public function pop():T
    return this.pop();

  // private
  inline function get_peek()    return this.first();
  inline function get_isEmpty() return this.isEmpty();
  inline function get_length()  return this.length;
}
