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
    output.out("\033[34m"+name+"\033[39m");
    var outputMessages = "";

    var onSuccess = function(msg) {
      outputMessages += " | \033[32m"+msg+"\033[39m";
    }

    var onFailure = function(msg) {
      this.numFails += 1;
      outputMessages += " | \033[31m"+msg+"\033[39m";
      throw new TestFinished();
    }

    var onPending = function(?msg) {
      if(msg == null)
        msg = "Not Implemented";
      outputMessages += " | \033[33m"+msg+"\033[39m";
      throw new TestFinished();
    }

    try {
      run(onSuccess, onFailure, onPending);
    } catch(_:TestFinished) {}
    output.out(outputMessages);
  }

  public function declareDescription(name, run) {
    output.out("\033[35m"+name+"\033[39m");
    run();
  }
}
