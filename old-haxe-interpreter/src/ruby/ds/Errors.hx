package ruby.ds;

// How do I access a backtrace?
// do I need to get a posinfos, or is that handled somehow by the throw?
class Errors {
  public var message:String;
  public function new(msg:String) {
    message = msg;
  }
}

class NothingToEvaluateError extends Errors {
  public function new(msg:String) {
    super(msg);
  }
}
