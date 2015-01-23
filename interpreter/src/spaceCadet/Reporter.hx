package spaceCadet;

typedef PassAssertion = String -> haxe.PosInfos -> Void;
typedef ReportPassing = Void   ->                  Void;
typedef ReportPending = String -> haxe.PosInfos -> Void;
typedef ReportFailing = String -> haxe.PosInfos -> Void;
typedef SpecCallbacks = PassAssertion
                     -> ReportPassing
                     -> ReportPending
                     -> ReportFailing
                     -> Void;

typedef RunSpecs = Void -> Void;

interface Reporter {
  public function declareSpec(name:String, run:SpecCallbacks): Void;
  public function declareDescription(name:String, run:RunSpecs):Void;
}

enum SpecEvent {
  Begin(         specName:String);
  PassAssertion( specName:String, pos:haxe.PosInfos, successMsgs:Array<String>);
  EndPassing(    specName:String);
  EndPending(    specName:String, pos:haxe.PosInfos, pendingMsg:String);
  EndFailing(    specName:String, pos:haxe.PosInfos, successMsgs:Array<String>, failureMsg:String);
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

  public function declareSpec(name, run:SpecCallbacks) {
    var successMsgs = [];
    specLine(Begin(name));

    var passAssertion = function(msg, pos) {
      successMsgs.push(msg);
      specLine(PassAssertion(name, pos, successMsgs));
    }

    var onPass = function() {
      specLine(EndPassing(name));
    }

    var onPending = function(msg, pos) {
      if(msg == null) msg = "Not Implemented";
      specLine(EndPending(name, pos, msg));
    }

    var onFailure = function(msg, pos) {
      this.numFails += 1;
      specLine(EndFailing(name, pos, successMsgs, msg));
    }

    run(passAssertion, onPass, onPending, onFailure);
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
      case EndPending(specName, pos, pendingMsg):
      output
        .fgYellow
          .resetln
          .writeln(EscapeString.call(specName) + " (" + pos.fileName + ":" + pos.lineNumber + ")")
          .indent
            .writeln(EscapeString.call(pendingMsg))
            .outdent
          .fgPop;
      case EndFailing(specName, pos, successMsgs, failureMsg):
      output
        .fgRed
          .resetln
          .writeln(EscapeString.call(specName) + " (" + pos.fileName + ":" + pos.lineNumber + ")")
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
      case PassAssertion(specName, pos, successMsgs):
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
