package spaceCadet;

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
