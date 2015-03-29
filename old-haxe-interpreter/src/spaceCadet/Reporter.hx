package spaceCadet;
using Inspect;

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
  public function finished():Void;
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
  public var output:Printer;
  public var numSpecs      = 0;
  public var numAssertions = 0;
  public var numPassed     = 0;
  public var numPending    = 0;
  public var numFailed     = 0;
  public var numErrored    = 0;
  public function new(output:Printer) {
    this.output = output;
  }

  public function declareSpec(name, run:SpecCallbacks) {
    numSpecs++;
    var successMsgs = [];
    specLine(Begin(name));

    var passAssertion = function(msg, pos) {
      numAssertions++;
      numPassed++;
      successMsgs.push(msg);
      specLine(PassAssertion(name, pos, successMsgs));
    }

    var onPass = function() {
      specLine(EndPassing(name));
    }

    var onPending = function(msg, pos) {
      numAssertions++;
      numPending++;
      if(msg == null) msg = "Not Implemented";
      specLine(EndPending(name, pos, msg));
    }

    var onFailure = function(msg, pos) {
      numAssertions++;
      this.numFailed += 1;
      specLine(EndFailing(name, pos, successMsgs, msg));
    }

    var onUncaught = function(thrown, backtrace) {
      numAssertions++;
      this.numErrored += 1;
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

  public function finished() {
    function delimit() output.fgWhite.write(' | ').fgPop;
    output.writeln('')
          .fgBlue.write('Assertions: ${numAssertions}').yield(delimit).fgPop
          .fgGreen.write('Passed: ${numPassed}').fgPop;

    if(numPassed  != 0) output.yield(delimit).fgYellow.write('Pending: ${numPending}').fgPop;
    if(numFailed  != 0) output.yield(delimit).fgRed.write('Failed: ${numFailed}').fgPop;
    if(numErrored != 0) output.yield(delimit).fgRed.write('Errors: ${numErrored}').fgPop;

    output.writeln('');
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
            .writeln('UNCAUGHT: ${thrown.inspect()}')
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
        case _: throw('I don\'t know what kind of stack item this is: ${stackItem.inspect()}');
      }
    }
  }
}
