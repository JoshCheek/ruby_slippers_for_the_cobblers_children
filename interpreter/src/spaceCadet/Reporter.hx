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

class TestFinished {
  public function new() {}
}

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
    specLine("begin", name, successMsgs, failureMsg, pendingMsg);

    var onSuccess = function(msg) {
      successMsgs.push(msg);
      specLine("passAssertion", name, successMsgs, failureMsg, pendingMsg);
    }

    var onFailure = function(msg) {
      this.numFails += 1;
      failureMsg     = msg;
      throw new TestFinished();
    }

    var onPending = function(?msg) {
      if(msg == null) msg = "Not Implemented";
      pendingMsg = msg;
      throw new TestFinished();
    }

    try {
      run(onSuccess, onFailure, onPending);
    } catch(_:TestFinished) {}

    if(failureMsg != null)
      specLine("fail", name, successMsgs, failureMsg, pendingMsg);
    else if(pendingMsg != null)
      specLine("pending", name, successMsgs, failureMsg, pendingMsg);
    else
      specLine("pass", name, successMsgs, failureMsg, pendingMsg);
  }

  public function declareDescription(name, run) {
    output.fgMagenta
            .writeln(name)
            .fgPop
          .indent
            .yield(run)
            .outdent;
  }

  private function specLine(status:String, specName:String, successMsgs:Array<String>, failureMsg:String, pendingMsg:String) {
    if(status == "begin")
      output
        .fgBlue
          .write(specName)
          .fgPop;
    else if(status == "pass")
      output
        .fgGreen
          .resetln
          .writeln(specName)
          .fgPop;
    else if(status == "pending")
      output
        .fgYellow
          .resetln
          .writeln(specName)
          .indent
            .writeln(pendingMsg)
            .outdent
          .fgPop
    else if(status == "fail") {
      output
        .fgRed
          .resetln
          .writeln(specName)
          .fgPop
        .indent
          .fgGreen
            .yield(function() for(msg in successMsgs) output.writeln(msg))
            .fgPop
          .fgRed
            .writeln(failureMsg)
            .fgPop
          .outdent;
    }
    else if(status == "passAssertion")
      output
        .fgBlue
          .resetln
          .write(specName)
          .fgPop
        .fgWhite
          .write(" - ")
          .fgPop
        .fgGreen
          .write(successMsgs[successMsgs.length-1])
          .fgPop;
  }
}
