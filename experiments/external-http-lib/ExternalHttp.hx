// still need a browser version :/

class ExternalHttp {
  public static function main() {
    MyHttp.init();
    MyHttp.post('http://localhost:3003/', '1+1', function(body) {
      trace("BODY: " + body);
    });
  }
}

#if js
// NODE!!! Wat is this? :(
// get inspired, yo! https://github.com/rest-client/rest-client#usage-raw-url
typedef NodeReqCb = ClientRequest->Void;

interface ClientRequest {
  public function setEncoding(encoding:String):Void;
  public function on(eventName:String, cb:String->Void):Void;
  public function write(data:String):Void;
  public function end():Void;
}
extern class NodeHttp {
  public static function request(options:{}, callback:NodeReqCb):ClientRequest;
}
extern class NodeUrl {
  public static function parse(url:String):{};
}

// Getting pretty far with this stupid hack, it ultimately amounts in `MyHttp.nodeHttp = require('http');`
@:native("require('http')") extern class NodeHttpInit { }
@:native("require('url')")  extern class NodeUrlInit  { }

class MyHttp {
  @:extern public static var nodeHttp:Dynamic; // ideally I can tell it this is a NodeHttpInit
  @:extern public static var nodeUrl:Dynamic;  // ideally I can tell it this is a NodeUrlInit
  public static inline function init() {
    nodeHttp = NodeHttpInit;
    nodeUrl  = NodeUrlInit;
  }

  public static function post(url:String, data:String, callback:String->Void):Void {
    var postOptions     = nodeUrl.parse(url);
    postOptions.method  = 'POST';
    postOptions.headers = { 'Content-Type': 'application/x-www-form-urlencoded', 'Content-Length': data.length }
    var request         = nodeHttp.request(postOptions, function(res) {
      res.setEncoding('utf8');
      res.on('data', callback);
    });
    request.write(data);
    request.end();
  }
}
#else
class MyHttp {
  public static function init() {};
  public static function post(url:String, data:String, callback:String->Void):Void {
    var request      = new haxe.Http(url);
    var resultBody   = "";
    request.onData   = callback;
    request.onError  = function(message) throw("HTTP ERROR: " + message);
    request.onStatus = function(status) { };
    request.setPostData(data);
    request.request(true);
  }
}
#end
