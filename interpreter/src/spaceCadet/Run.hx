package spaceCadet;

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
        case One(name, body):   runSpec(name, allBeforeBlocks, body);
        case Many(name, child): runDesc(name, allBeforeBlocks, child);
      }
    }
  }

  private function runSpec(name, beforeBlocks:Array<AssertBlock>, body) {
    reporter.declareSpec(name, function(reportSuccess, reportFailure, reportPending) {
      var onFailure = function(msg) {
        reportFailure(msg);
        throw new TestFinished();
      }

      var onPending = function(?msg) {
        reportPending(msg);
        throw new TestFinished();
      }

      var asserter = new Asserter(reportSuccess, onFailure, onPending);

      try {
        for(block in beforeBlocks) block(asserter);
        body(asserter);
      } catch(_:TestFinished) {}
    });
  }

  private function runDesc(name, beforeBlocks, description) {
    reporter.declareDescription(name, function() {
      _run(description, beforeBlocks);
    });
  }
}
