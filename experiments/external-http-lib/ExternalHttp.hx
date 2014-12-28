// runs in node.js, the browser, and neko
class ExternalHttp {
  public static function main() {
    var body = null;
    var body = MyHttp.post('http://localhost:3003/', '1+1');
    trace("RETURNED: " + body);
  }
}

#if !(js && node)
// this will be all non node.js code (e.g. browser js and neko)
class MyHttp {
  public static function post(url:String, data:String):String {
    var request      = new haxe.Http(url);
    var resultBody   = "";
    request.onData   = function(chunk)   resultBody += chunk;
    request.onError  = function(message) throw("HTTP ERROR: " + message);
    request.onStatus = function(status)  { };
    request.setPostData(data);
    request.request(true);
    return resultBody;
  }
}

#else
typedef NodeReqCb = ClientRequest->Void;

interface ClientRequest {
  public function setEncoding(encoding:String):Void;
  public function on(eventName:String, cb:String->Void):Void;
  public function write(data:String):Void;
  public function end():Void;
}
extern class NodeHttp {
  public function request(options:{}, callback:NodeReqCb):ClientRequest;
}
extern class NodeUrl {
  public function parse(url:String):{ slashes:  Bool,
                                      host:     String,
                                      href:     String,
                                      port:     String,
                                      path:     String,
                                      method:   String,
                                      protocol: String,
                                      hostname: String,
                                      pathname: String,
                                      headers:  Dynamic }; // have to do Dynamic b/c it can't deal with a key like 'Content-Type' :/
}

@:initPackage
class MyHttp {
  @:extern public static var nodeHttp:NodeHttp;
  @:extern public static var nodeUrl:NodeUrl;
	public static function __init__() : Void untyped {
    nodeHttp = untyped __js__("require('http')");
    nodeUrl  = untyped __js__("require('url')");
	}

  public static function post(url:String, data:String):String {
    var postOptions     = nodeUrl.parse(url);
    postOptions.headers = { 'Content-Type':  'application/x-www-form-urlencoded', 'Content-Length': data.length };
    postOptions.method  = 'POST';
    var resultBody      = "";
    var request         = nodeHttp.request(postOptions, function(res) {
      res.setEncoding('utf8');
      res.on('data', function(chunk) {
        trace("CHUNK: " + chunk);
        resultBody += chunk;
      });
    });
    request.write(data);
    request.end();
    return resultBody;
  }
}
#end
