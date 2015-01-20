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

  public function new(onSuccess, onFailure) {
    this.onSuccess = onSuccess;
    this.onFailure = onFailure;
  }

  public function eqm<T>(a:T, b:T, m:String) {
    if(a == b) onSuccess(m);
    else       onFailure(m);
  }

  public function eq<T>(a:T, b:T) {
    var msg = "Expect " + Std.string(a) + " to == " + Std.string(b);
    eqm(a, b, msg);
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

  public function describe(name:String, body:Description->Void):Description {
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

class DescribeStack {
  public static function describe(d:Description) {
    d.describe('Stack Test', function(d) {
      var int_stack    : Array<Int>;
      var string_stack : Array<String>;

      d.before(function(lg) {
        int_stack    = new Array<Int>();
        string_stack = new Array<String>();
      });

      d.it('has 0 length initially', function(a) {
        a.eq(int_stack.length, 0);
        a.eq(string_stack.length, 0);
        a.eq(string_stack.length, 1);
        a.eq(string_stack.length, 0);
      });
    });
  }
}

class Reporter {
  public var output:Output;
  public function new(output:Output) {
    this.output = output;
  }

  public function declareSpec(name, run) {
    output.out("SPECIFICATION: " + name);
    var onSuccess = function(msg:String) {
      output.out("SUCCESS: " + msg);
    }

    var onFailure = function(msg:String) {
      output.out("FAILURE: " + msg);
      throw new TestFinished();
    }

    try {
      run(onSuccess, onFailure);
    } catch(_:TestFinished) {}
    // output.out("SPEC: " + name + " -- SUCCESSES: " + Std.string(successes) + " FAILURE: " + failMsg);
  }

  public function declareDescription(name, run) {
    output.out("BEGIN : " + name);
    run();
    output.out("END: " + name);
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
    reporter.declareSpec(name, function(onSuccess, onFailure) {
      var asserter = new Asserter(onSuccess, onFailure);
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

class RunTests2 {
  static function main() {
    // define tests
    var root = new Description();
    DescribeStack.describe(root);

    var output   = new Output(Sys.stdout(), Sys.stderr());
    var reporter = new Reporter(output);
    Run.run(root, reporter);

    // if(!allPassed) Sys.exit(1);
  }
}
