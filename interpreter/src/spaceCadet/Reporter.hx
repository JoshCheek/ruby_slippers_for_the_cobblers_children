package spaceCadet;

typedef PassAssertion  = String -> haxe.PosInfos -> Void;
typedef ReportPassing  = Void   ->                  Void;
typedef ReportPending  = String -> haxe.PosInfos -> Void;
typedef ReportFailing  = String -> haxe.PosInfos -> Void;
typedef ReportUncaught = Dynamic -> Array<haxe.CallStack.StackItem> -> Void;
typedef SpecCallbacks  = PassAssertion
                      -> ReportPassing
                      -> ReportPending
                      -> ReportFailing
                      -> ReportUncaught
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
  EndErrored(    specName:String, thown:Dynamic, backtrace:Array<haxe.CallStack.StackItem>);
}

// Feels backwards that the reporter receives the run blocks,
// but I don't think it would be possible to make an async reporter
// if we didn't (even though this reporter is not async b/c it progressively writes to the stream)
//
// I think it will need to pass the runDesc a callback in order to truly be able to handle async,
// but seems better to wait until I need that feature than to try and guess right now.
class StreamReporter implements Reporter {
  public var output:Output;
  public var numFails  = 0;
  public var numErrors = 0;
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

    var onUncaught = function(thrown, backtrace) {
      this.numErrors += 1;
      specLine(EndErrored(name, thrown, backtrace));
    }

    run(passAssertion, onPass, onPending, onFailure, onUncaught);
  }

  public function declareDescription(name, run) {
    output.fgWhite
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
      case PassAssertion(specName, pos, successMsgs):
      output
        .fgYellow
          .resetln
          .write(EscapeString.call(specName) + " ")
          .fgPop
        .fgGreen
          .write(EscapeString.call(successMsgs[successMsgs.length-1]))
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
          .fgPop
        .indent
          .fgCyan
            .writeln(EscapeString.call(pendingMsg))
            .fgPop
          .outdent;
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
      case EndErrored(specName, thrown, backtrace):
      output
        .fgRed
          .resetln
          .writeln(EscapeString.call(specName))
          .fgPop
        .indent
          .fgWhite
            .writeln('UNCAUGHT: ${Inspect.call(thrown)}')
            .fgPop
          .yield(function() printBacktrace(backtrace))
          .outdent;
    }
  }

  function printBacktrace(backtrace:Array<haxe.CallStack.StackItem>) {
    for(stackItem in backtrace) {
      switch(stackItem) {
        case FilePos(idk, filename, line):
          output.fgCyan.write(filename).fgPop
                .fgWhite.write(":").fgPop
                .fgBlue.writeln(Std.string(line)).fgPop;
        case _: throw('I don\'t know what kind of stack item this is: ${Inspect.call(stackItem)}');
      }
    }
  }
}
