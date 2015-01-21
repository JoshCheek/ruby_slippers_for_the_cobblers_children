package spaceCadet;

class SpaceCadet {
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
  public function context(name, body) return describe(name, body);

  public function before(beforeBlock) {
    this.beforeBlocks.push(beforeBlock);
    return this;
  }

  public function it(name, body) {
    this.testables.push(One(name, body));
    return this;
  }

  // why can't I do this?: public function specify = it;
  public function specify(name, body) return it(name, body);
  public function example(name, body) return it(name, body);
}

interface Reporter {
  public function declareSpec(name:String, run:
      (String->Void)->(String->Void)->(String->Void)->Void):Void;
  public function declareDescription(name:String, run:Void->Void):Void;
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
