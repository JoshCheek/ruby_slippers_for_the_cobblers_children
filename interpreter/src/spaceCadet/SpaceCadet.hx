package spaceCadet;

class SpaceCadet {
}

class Output {
  var outstream:haxe.io.Output;
  var errstream:haxe.io.Output;

  public function new(outstream, errstream) {
    this.outstream = outstream;
    this.errstream = errstream;
  }

  public function out(message) {
    this.outstream.writeString(message);
    this.outstream.writeString("\n");
    return this;
  }
}

class Asserter {
  private var onSuccess : String -> Void;
  private var onFailure : String -> Void;
  private var onPending : String -> Void;

  public function new(onSuccess, onFailure, onPending) {
    this.onSuccess = onSuccess;
    this.onFailure = onFailure;
    this.onPending = onPending;
  }

  public function eqm<T>(a:T, b:T, message) {
    if(a == b) onSuccess(message);
    else       onFailure(message);
  }

  public function eq<T>(a:T, b:T) {
    var msg = "Expect " + Std.string(a) + " to == " + Std.string(b);
    eqm(a, b, msg);
  }

  public function pending(reason="Not Implemented") {
    onPending(reason);
  }
}

typedef AssertBlock = Asserter -> Void;

enum Testable {
  One(name:String,  body:AssertBlock);
  Many(name:String, desc:Description);
}

class Description {
  public var beforeBlocks : Array<AssertBlock>;
  public var testables    : Array<Testable>;

  public function new() {
    this.beforeBlocks = [];
    this.testables    = [];
  }

  public function describe(name, body) {
    var child = new Description();
    testables.push(Many(name, child));
    body(child);
    return this;
  }

  public function before(beforeBlock) {
    this.beforeBlocks.push(beforeBlock);
    return this;
  }

  public function it(name, body) {
    this.testables.push(One(name, body));
    return this;
  }
}

interface Reporter {
  public function declareSpec(name:String, run:
      (String->Void)->(String->Void)->(String->Void)->Void):Void;
  public function declareDescription(name:String, run:Void->Void):Void;
}

class StreamReporter implements Reporter {
  public var output:Output;
  public function new(output:Output) {
    this.output = output;
  }

  public function declareSpec(name, run) {
    output.out("\033[34m"+name+"\033[39m");
    var onSuccess = function(msg) {
      output.out("  \033[32m"+msg+"\033[39m");
    }

    var onFailure = function(msg) {
      output.out("  \033[31m"+msg+"\033[39m");
      throw new TestFinished();
    }

    var onPending = function(?msg) {
      if(msg == null)
        msg = "Not Implemented";
      output.out("  \033[33m"+msg+"\033[39m");
      throw new TestFinished();
    }

    try {
      run(onSuccess, onFailure, onPending);
    } catch(_:TestFinished) {}
    // output.out("SPEC: " + name + " -- SUCCESSES: " + Std.string(successes) + " FAILURE: " + failMsg);
  }

  public function declareDescription(name, run) {
    output.out("\033[35m"+name+"\033[39m");
    run();
  }
}

class TestFinished {
  public function new() {}
}


class Run {
  public static function run(desc:Description, rep:Reporter) {
    new Run(rep)._run(desc, []);
  }

  private var reporter:Reporter;

  public function new(reporter) {
    this.reporter = reporter;
  }

  private function _run(description:Description, beforeBlocks:Array<AssertBlock>) {
    var allBeforeBlocks = beforeBlocks.concat(description.beforeBlocks);
    for(testable in description.testables) {
      switch(testable) {
        case One(name, body):
          runSpec(name, allBeforeBlocks, body);
        case Many(name, child): runDesc(name, allBeforeBlocks, child);
      }
    }
  }

  private function runSpec(name, beforeBlocks:Array<AssertBlock>, body) {
    reporter.declareSpec(name, function(onSuccess, onFailure, onPending) {
      var asserter = new Asserter(onSuccess, onFailure, onPending);
      for(block in beforeBlocks) block(asserter);
      body(asserter);
    });
  }

  private function runDesc(name, beforeBlocks, description) {
    reporter.declareDescription(name, function() {
      _run(description, beforeBlocks);
    });
  }
}
