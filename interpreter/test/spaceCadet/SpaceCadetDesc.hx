package spaceCadet;
import spaceCadet.SpaceCadet;
using Lambda;

class DescData {
  public function new() {};
}
class MockReporter implements Reporter {
  private var specifications:Map<String, {numSucceeded:Int, didSucceed:Bool}>;
  private var descriptions:Map<String, DescData>;
  public function new() {
    this.descriptions   = new Map();
    this.specifications = new Map();
  }

  public function declareSpec(name, run) {
    var result = {numSucceeded: 0, didSucceed: true};
    specifications.set(name, result);

    var onSuccess = function(msg)
      result.numSucceeded++;

    var onFailure = function(msg) {
      result.didSucceed = false;
      throw new TestFinished();
    }

    var onPending = function(?msg) {
      throw new TestFinished();
    }

    try {
      run(onSuccess, onFailure, onPending);
    } catch(_:TestFinished) {}
    // output.out("SPEC: " + name + " -- SUCCESSES: " + Std.string(successes) + " FAILURE: " + failMsg);
  }

  public function declareDescription(name, run) {
    descriptions.set(name, new DescData());
    run();
  }

  public function wasDescribed(name) {
    return descriptions.exists(name);
  }

  public function wasSpecified(name) {
    return specifications.exists(name);
  }

  public function numSucceeded(name) {
    if(wasSpecified(name))
      specifications.get(name).numSucceeded;
    return 0;
  }

  public function didSucceed(name) {
    if(wasSpecified(name))
      return specifications.get(name).didSucceed;
    return false;
  }

  // sigh, this is so dumb
  public function childrenOf(name) {
    var children = [];
    for(child in specifications.keys()) children.push(child);
    for(child in descriptions.keys())   children.push(child);
    return children;
  }
}

class SpaceCadetDesc {
  public static function describe(d:Description) {
    var desc     : Description;
    var reporter : MockReporter;
    var run      : Void->Void;

    d.before(function(a) {
      desc     = new Description();
      reporter = new MockReporter();
      run      = function() Run.run(desc, reporter);
    });

    d.describe('Space Cadet', function(d) {
      d.describe('running a test suite', function(d) {
        d.it('reports describe blocks', function(a) {
          desc.describe("name", function(_) {});
          a.eq(false, reporter.wasDescribed("name"));
          run();
          a.eq(true, reporter.wasDescribed("name"));
        });

        d.it('reports specification blocks', function(a) {
          desc.it("name", function(_) {});
          a.eq(false, reporter.wasSpecified("name"));
          run();
          a.eq(true, reporter.wasSpecified("name"));
        });

        d.it('reports true assertions', function(a) {
          desc.it("name1", function(a) { a.eq(1, 1); a.eq(1, 1); });
          desc.it("name2", function(a) { a.eq(1, 1); });
          a.eq(0, reporter.numSucceeded("name1"));
          a.eq(0, reporter.numSucceeded("name2"));
          run();
          a.eq(2, reporter.numSucceeded("name1"));
          a.eq(1, reporter.numSucceeded("name2"));
        });

        d.it('reports failed assertions', function(a) {
          desc.it("name", function(a) a.eq(1, 2));
          a.eq(false, reporter.didSucceed("name"));
          run();
          a.eq(true, reporter.didSucceed("name"));
        });

        d.it('ends the spec when it sees a failed assertion', function(a) {
          desc.it("name", function(a) {
            a.eq(1, 1);
            a.eq(1, 2);
            a.eq(1, 1);
          });
          run();
          a.eq(1, reporter.numSucceeded("name"));
          a.eq(false, reporter.didSucceed("name"));
        });

        d.it('reports the specification as a child of the describe block', function(a) {
          desc.describe("out1", function(d) d.it("in1", function(_) {}));
          desc.describe("out2", function(d) d.it("in2", function(_) {}));
          run();
          a.eq(["in1"], reporter.childrenOf("out1"));
          a.eq(["in2"], reporter.childrenOf("out2"));
        });

        d.it('reports describe blocks as children of their parent', function(a) {
          desc.describe("out1", function(d) d.describe("in1", function(_) {}));
          desc.describe("out2", function(d) d.describe("in2", function(_) {}));
          run();
          a.eq(["in1"], reporter.childrenOf("out1"));
          a.eq(["in2"], reporter.childrenOf("out2"));
        });
      });

      d.it('runs the specs and describe blcks in the order they were described in', function(a) {
        a.pending();
      });

      d.describe('before blocks', function(d) {
        d.it('runs before blocks prior to each test', function(a) {
          a.pending();
        });
        d.it('runs before blcoks in the order they were defined in', function(a) {
          a.pending();
        });
        d.it('runs parent before blocks prior to children before blocks', function(a) {
          a.pending();
        });
        d.it('allows before blocks to make assertions', function(a) {
          a.pending();
        });
      });
    });
  }
}
