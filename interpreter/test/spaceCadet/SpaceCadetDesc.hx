package spaceCadet;
import spaceCadet.SpaceCadet;

class SpaceCadetDesc {
  public static function describe(d:Description) {
    d.describe('Space Cadet', function(d) {
      d.describe('running a test suite', function(d) {
        var desc     : Description;
        var reporter : MockReporter;
        var run      : Void->Void;

        d.before(function(a) {
          desc     = new Description();
          reporter = new MockReporter();
          run      = function() Run.run(desc, reporter);
        });

        d.it('reports describe blocks', function(a) {
          desc.describe("name", function(_) {});
          a.eq(false, reporter.wasDescribed("name"));
          run();
          a.eq(true, reporter.wasDescribed("name"));
        });

        d.it('can declare a describe block with #describe and #context', function(a) {
          desc.describe("name1", function(_) {});
          desc.context( "name2", function(_) {});
          a.eq(false, reporter.wasDescribed("name1"));
          a.eq(false, reporter.wasDescribed("name2"));
          run();
          a.eq(true, reporter.wasDescribed("name1"));
          a.eq(true, reporter.wasDescribed("name2"));
        });

        d.it('reports specification blocks', function(a) {
          desc.it("name", function(_) {});
          a.eq(false, reporter.wasSpecified("name"));
          run();
          a.eq(true, reporter.wasSpecified("name"));
        });

        d.it('can declare a specification with #it, #specify, and #example', function(a) {
          desc.it(     "name1", function(_) {});
          desc.specify("name2", function(_) {});
          desc.example("name3", function(_) {});
          a.eq(false, reporter.wasSpecified("name1"));
          a.eq(false, reporter.wasSpecified("name2"));
          a.eq(false, reporter.wasSpecified("name3"));
          run();
          a.eq(true, reporter.wasSpecified("name1"));
          a.eq(true, reporter.wasSpecified("name2"));
          a.eq(true, reporter.wasSpecified("name3"));
        });

        d.it('reports passed and failed assertions', function(a) {
          desc.it("name1", function(a) { a.eq(1, 1); a.eq(1, 1); });
          desc.it("name2", function(a) { a.eq(1, 1); });
          desc.it("name3", function(a) { a.eq(1, 2); });
          a.eq(0, reporter.numSucceeded("name1"));
          a.eq(0, reporter.numSucceeded("name2"));
          run();
          a.eq(2, reporter.numSucceeded("name1"));
          a.eq(1, reporter.numSucceeded("name2"));
        });

        d.it("reports failed assertions", function(a) {
          desc.it("name1", function(a) a.eq(1, 1));
          desc.it("name2", function(a) a.eq(1, 2));
          a.eq(false, reporter.didSucceed("name1"));
          a.eq(false, reporter.didSucceed("name2"));
          run();
          a.eq(true,  reporter.didSucceed("name1"));
          a.eq(false, reporter.didSucceed("name2"));
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
          a.streq(["in1"], reporter.childrenOf("out1"));
          a.streq(["in2"], reporter.childrenOf("out2"));
        });

        d.it('reports describe blocks as children of their parent', function(a) {
          desc.describe("out1", function(d) d.describe("in1", function(_) {}));
          desc.describe("out2", function(d) d.describe("in2", function(_) {}));
          run();
          a.streq(["in1"], reporter.childrenOf("out1"));
          a.streq(["in2"], reporter.childrenOf("out2"));
        });

        d.it('allows multiple describe blocks with the same name', function(a) {
          desc.describe("desc", function(_) {});
          desc.describe("desc", function(_) {});
          a.eq(2, desc.testables.length);
          for(t in desc.testables) {
            switch(t) {
              case Many(name, desc): a.eq("desc", name);
              case _: throw("GOT: " + Std.string(t));
            }
          }
        });

        d.it('allows multiple specification blocks with the same name', function(a) {
          desc.it("spec", function(_) {});
          desc.it("spec", function(_) {});
          a.eq(2, desc.testables.length);
          for(t in desc.testables) {
            switch(t) {
              case One(name, body): a.eq("spec", name);
              case _: throw("GOT: " + Std.string(t));
            }
          }
        });
      });

      d.describe("Assertions", function(d) {
        var successMessage:String = null;
        var failureMessage:String = null;
        var pendingMessage:String = null;
        var onSuccess = function(m) { successMessage = m; };
        var onFailure = function(m) { failureMessage = m; };
        var onPending = function(m) { pendingMessage = m; };
        var asserter  = new Asserter(onSuccess, onFailure, onPending);

        d.before(function(a) {
          successMessage = null;
          failureMessage = null;
          pendingMessage = null;
        });

        // positive assertions
        d.specify("eq passes when objects are ==", function(a) {
          a.eq(null, successMessage);
          asserter.eq(1, 2);
          a.eq(null, successMessage);
          asserter.eq(1, 1);
          a.eq(false, successMessage == null);
        });

        d.specify("eqm is the same as eq, but with a custom message",function(a) {
          a.eq(null, successMessage);
          asserter.eqm(1, 2, "zomg");
          a.eq(null, successMessage);
          asserter.eqm(1, 1, "zomg");
          a.eq("zomg", successMessage);
        });

        d.specify("streq passes when objects string representations are ==", function(a) {
          a.eq(null, successMessage);
          asserter.streq({}, {a:1});
          a.eq(null, successMessage);
          asserter.streq({}, {});
          a.eq(false, successMessage==null);
        });

        d.specify("streqm is the same as streq, but with a custom message",function(a) {
          a.eq(null, successMessage);
          asserter.streqm({}, {a:1}, "zomg");
          a.eq(null, successMessage);
          asserter.streqm({}, {}, "zomg");
          a.eq("zomg", successMessage);
        });

        // negative assertions
        d.specify("neq fails when objects are ==", function(a) {
          a.eq(null, successMessage);
          asserter.neq(1, 1);
          a.eq(null, successMessage);
          asserter.neq(1, 2);
          a.eq(false, successMessage == null);
        });

        d.specify("neqm is the same as neq, but with a custom message",function(a) {
          a.eq(null, successMessage);
          asserter.neqm(1, 1, "zomg");
          a.eq(null, successMessage);
          asserter.neqm(1, 2, "zomg");
          a.eq("zomg", successMessage);
        });

        d.specify("nstreq fails when objects string representations are ==", function(a) {
          a.eq(null, successMessage);
          asserter.nstreq({}, {});
          a.eq(null, successMessage);
          asserter.nstreq({}, {a:1});
          a.eq(false, successMessage==null);
        });

        d.specify("nstreqm is the same as nstreq, but with a custom message",function(a) {
          a.eq(null, successMessage);
          asserter.nstreqm({}, {}, "zomg");
          a.eq(null, successMessage);
          asserter.nstreqm({}, {a:1}, "zomg");
          a.eq("zomg", successMessage);
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
