class ParseCode {
  // haxe -x PostCode.hx
  // {"type":"send","target":{"type":"integer","value":"1"},"message":"+","args":[{"type":"integer","value":"1"}]}
  public static function main() {
    var parser = new haxe.Http("http://localhost:3003");
    parser.setPostData("1+1");
    parser.onData = function(data) trace(data);
    parser.request(true);
  }
}
