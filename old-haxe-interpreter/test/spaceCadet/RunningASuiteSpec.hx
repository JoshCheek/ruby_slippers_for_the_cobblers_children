package spaceCadet;

class RunningASuiteSpec {
  public static function describe(d:Description) {
    d.describe('running a Space Cadet test suite', function(d) {
      var noop = function(_:Dynamic) { };

      var desc     : Description;
      var reporter : MockReporter;
      var run      : Void->Void;

      d.before(function(a) {
        desc     = new Description();
        reporter = new MockReporter();
        run      = function() Run.run(desc, reporter);
      });

      d.it('reports describe blocks', function(a) {
        desc.describe("name", noop);
        a.eq(false, reporter.wasDescribed("name"));
        run();
        a.eq(true, reporter.wasDescribed("name"));
      });

      d.it('can declare a describe block with #describe and #context', function(a) {
        desc.describe("name1", noop);
        desc.context( "name2", noop);
        a.eq(false, reporter.wasDescribed("name1"));
        a.eq(false, reporter.wasDescribed("name2"));
        run();
        a.eq(true, reporter.wasDescribed("name1"));
        a.eq(true, reporter.wasDescribed("name2"));
      });

      d.it('reports specification blocks', function(a) {
        desc.it("name", noop);
        a.eq(false, reporter.wasSpecified("name"));
        run();
        a.eq(true, reporter.wasSpecified("name"));
      });

      d.it('can declare a specification with #it, #specify, and #example', function(a) {
        desc.it(     "name1", noop);
        desc.specify("name2", noop);
        desc.example("name3", noop);
        a.eq(false, reporter.wasSpecified("name1"));
        a.eq(false, reporter.wasSpecified("name2"));
        a.eq(false, reporter.wasSpecified("name3"));
        run();
        a.eq(true, reporter.wasSpecified("name1"));
        a.eq(true, reporter.wasSpecified("name2"));
        a.eq(true, reporter.wasSpecified("name3"));
      });

      d.it('reports each passing assertion', function(a) {
        desc.it("name1", function(a) { a.eq(1, 1); a.eq(1, 1); });
        desc.it("name2", function(a) { a.eq(1, 1); });
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

      d.it("reports pending specs", function(a) {
        desc.it("notPending", noop);
        desc.it("isPending", function(a) { a.pending("in a bit, yo!"); });
        a.eq(false, reporter.isPending("notPending"));
        a.eq(false, reporter.isPending("isPending"));
        run();
        a.eq(false, reporter.isPending("notPending"));
        a.eq(true,  reporter.isPending("isPending"));
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
        a.eq(false, reporter.didThrow("name"));
      });

      d.it('ends the spec and reports when it sees an exception', function(a) {
        var lineno = -1;
        desc.it("up", function(a) {
          a.eq(1, 1);
          lineno = 1 + function(?p:haxe.PosInfos) { return p.lineNumber; }();
          throw("zomg!");
          a.eq(1, 1);
        });
        a.eq(false, reporter.didThrow("up"));
        run();
        a.eq(1, reporter.numSucceeded("up"));
        a.eq(false, reporter.didSucceed("up"));
        a.eq(true, reporter.didThrow("up"));
        a.eq("zomg!", reporter.thrown("up"));
        a.eq(lineno, reporter.thrownLine("up"));
      });

      d.it('reports the specification as a child of the describe block', function(a) {
        desc.describe("out1", function(d) d.it("in1", noop));
        desc.describe("out2", function(d) d.it("in2", noop));
        run();
        a.streq(["in1"], reporter.childrenOf("out1"));
        a.streq(["in2"], reporter.childrenOf("out2"));
      });

      d.it('reports describe blocks as children of their parent', function(a) {
        desc.describe("out1", function(d) d.describe("in1", noop));
        desc.describe("out2", function(d) d.describe("in2", noop));
        run();
        a.streq(["in1"], reporter.childrenOf("out1"));
        a.streq(["in2"], reporter.childrenOf("out2"));
      });

      d.it('allows multiple describe blocks with the same name', function(a) {
        desc.describe("desc", noop);
        desc.describe("desc", noop);
        a.eq(2, desc.testables.length);
        for(t in desc.testables) {
          switch(t) {
            case Many(name, desc): a.eq("desc", name);
            case _: throw("GOT: " + Std.string(t));
          }
        }
      });

      d.it('allows multiple specification blocks with the same name', function(a) {
        desc.it("spec", noop);
        desc.it("spec", noop);
        a.eq(2, desc.testables.length);
        for(t in desc.testables) {
          switch(t) {
            case One(name, body): a.eq("spec", name);
            case _: throw("GOT: " + Std.string(t));
          }
        }
      });

      d.it('runs the specs and describe blcks in the order they were described in', function(a) {
        desc.describe("d1", function(d) {
          d.it("d1s1", noop);
          d.it("d1s2", noop);
        }).describe("d2", function(d) {
          d.it("d2s1", noop);
          d.describe("d2d3", function(d) {
            d.it("d2d3s1", noop);
          });
          d.it("d2s2", noop);
        });
        a.streq([], reporter.orderDeclared);
        run();
        a.streq(["d1",
                 "d1s1",
                 "d1s2",
                 "d2",
                 "d2s1",
                 "d2d3",
                 "d2d3s1",
                 "d2s2"],
                 reporter.orderDeclared);
      });

      d.it('ends the suite immediately when it sees a failure, and failFast is set', function(a) {
        desc.describe("d1", function(d) {
          d.describe("d1d1", function(d) {
            d.it("d1d1s1", noop);                  // pass
            d.it("d1d1s2", function(a) a.eq(1,2)); // fail
            d.it("d1d1s3", noop);                  // skip
          });
          d.it("d1s1", noop);                      // skip
          d.describe("d1d2", function(d) {
            d.it("d1d2s1", noop);                  // skip
          });
        });

        // not set
        reporter = new MockReporter();
        Run.run(desc, reporter, {});
        a.streq(["d1",
                 "d1d1",
                 "d1d1s1",
                 "d1d1s2",
                 "d1d1s3",
                 "d1s1",
                 "d1d2",
                 "d1d2s1"],
                 reporter.orderDeclared);

        // set
        reporter = new MockReporter();
        Run.run(desc, reporter, {failFast: true});
        a.streq(["d1", "d1d1", "d1d1s1", "d1d1s2"], reporter.orderDeclared);
      });

      d.it('ends the suite immediately when it sees an error, and failFast is set', function(a) {
        desc.describe("d1", function(d) {
          d.describe("d1d1", function(d) {
            d.it("d1d1s1", noop);                    // pass
            d.it("d1d1s2", function(a) throw("up")); // fail
            d.it("d1d1s3", noop);                    // skip
          });
          d.it("d1s1", noop);                        // skip
          d.describe("d1d2", function(d) {
            d.it("d1d2s1", noop);                    // skip
          });
        });

        // not set
        reporter = new MockReporter();
        Run.run(desc, reporter, {});
        a.streq(["d1",
                 "d1d1",
                 "d1d1s1",
                 "d1d1s2",
                 "d1d1s3",
                 "d1s1",
                 "d1d2",
                 "d1d2s1"],
                 reporter.orderDeclared);

        // set
        reporter = new MockReporter();
        Run.run(desc, reporter, {failFast: true});
        a.streq(["d1", "d1d1", "d1d1s1", "d1d1s2"], reporter.orderDeclared);
      });

      d.it('informs the reporter when its finished', function(a) {
        a.eq(false, reporter.isFinished);
        run();
        a.eq(true, reporter.isFinished);
      });
    });
  }
}
