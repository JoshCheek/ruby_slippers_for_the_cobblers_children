package spaceCadet;

interface Reporter {
  public function declareSpec(
    name : String,
    run  : (String->Void)->(String->Void)->(String->Void)->Void
  ) : Void;

  public function declareDescription(
    name : String,
    run  : Void->Void
  ) : Void;
}

enum SpecEvent {
  Begin(specName:String);
  PassAssertion(specName:String, successMsgs:Array<String>);
  EndPassing(specName:String);
  EndPending(specName:String, pendingMsg:String);
  EndFailing(specName:String, successMsgs:Array<String>,  failureMsg:String);
}

// Feels backwards that the reporter receives the run blocks,
// but I don't think it would be possible to make an async reporter
// if we didn't (even though this reporter is not async b/c it progressively writes to the stream)
//
// I think it will need to pass the runDesc a callback in order to truly be able to handle async,
// but seems better to wait until I need that feature than to try and guess right now.
class StreamReporter implements Reporter {
  public var output:Output;
  public var numFails = 0;
  public function new(output:Output) {
    this.output = output;
  }

  public function declareSpec(name, run) {
    var successMsgs = [];
    var failureMsg  = null;
    var pendingMsg  = null;
    specLine(Begin(name));

    var onSuccess = function(msg) {
      successMsgs.push(msg);
      specLine(PassAssertion(name, successMsgs));
    }

    var onFailure = function(msg) {
      this.numFails += 1;
      failureMsg     = msg;
    }

    var onPending = function(?msg) {
      if(msg == null) msg = "Not Implemented";
      pendingMsg = msg;
    }

    run(onSuccess, onFailure, onPending);

    if(failureMsg != null)
      specLine(EndFailing(name, successMsgs, failureMsg));
    else if(pendingMsg != null)
      specLine(EndPending(name, pendingMsg));
    else
      specLine(EndPassing(name));
  }

  public function declareDescription(name, run) {
    output.fgMagenta
            .writeln(EscapeString.call(name))
            .fgPop
          .indent
            .yield(run)
            .outdent;
  }

  private function specLine(status:SpecEvent) {
    switch(status) {
      case Begin(specName):
      output
        .fgYellow
          .write(EscapeString.call(specName))
          .fgPop;
      case EndPassing(specName):
      output
        .fgGreen
          .resetln
          .writeln(EscapeString.call(specName))
          .fgPop;
      case EndPending(specName, pendingMsg):
      output
        .fgYellow
          .resetln
          .writeln(EscapeString.call(specName))
          .indent
            .writeln(EscapeString.call(pendingMsg))
            .outdent
          .fgPop;
      case EndFailing(specName, successMsgs, failureMsg):
      output
        .fgRed
          .resetln
          .writeln(EscapeString.call(specName))
          .fgPop
        .indent
          .fgGreen
            .yield(function() for(msg in successMsgs)
                     output.writeln(EscapeString.call(msg)))
            .fgPop
          .fgRed
            .writeln(EscapeString.call(failureMsg))
            .fgPop
          .outdent;
      case PassAssertion(specName, successMsgs):
      output
        .fgYellow
          .resetln
          .write(EscapeString.call(specName) + " ")
          .fgPop
        .fgGreen
          .write(EscapeString.call(successMsgs[successMsgs.length-1]))
          .fgPop;
    }
  }
}
