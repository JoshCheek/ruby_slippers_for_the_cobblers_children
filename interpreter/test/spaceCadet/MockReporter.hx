package spaceCadet;
import spaceCadet.Reporter;
using Inspect;

typedef SpecState = {
  numSucceeded : Int,
  didSucceed   : Bool,
  isPending    : Bool,
  didThrow     : Bool,
  thrown       : Dynamic,
  backtrace    : Array<haxe.CallStack.StackItem>,
}

class DescData {
  public var specifications : Map<String, SpecState>;
  public var descriptions   : Map<String, DescData>;
  public function new() {
    this.descriptions   = new Map();
    this.specifications = new Map();
  };
}


class MockReporter implements Reporter {
  public var crnt          = new DescData();
  public var orderDeclared = [];
  public var isFinished    = false;
  public function new() {}

  public function declareSpec(name, run) {
    orderDeclared.push(name);
    var result = {numSucceeded:0, didSucceed:true, isPending:false, didThrow:false, thrown:null, backtrace:[]};
    crnt.specifications.set(name, result);

    var passAssertion = function(msg, pos)
      result.numSucceeded++;

    var onPass = function() {}

    var onFailure = function(msg, pos)
      result.didSucceed = false;

    var onPending = function(msg, pos) {
      result.isPending  = true;
      result.didSucceed = false;
    }

    var onUncaught = function(thrown:Dynamic, backtrace:Array<haxe.CallStack.StackItem>) {
      result.didSucceed = false;
      result.didThrow   = true;
      result.thrown     = thrown;
      result.backtrace  = backtrace;
    }

    run(passAssertion, onPass, onPending, onFailure, onUncaught);
  }

  public function declareDescription(name, run) {
    orderDeclared.push(name);
    var oldDesc = this.crnt;
    var data    = new DescData();
    this.crnt   = data;
    oldDesc.descriptions.set(name, data);
    run();
    this.crnt   = oldDesc;
  }

  public function finished() {
    isFinished = true;
  }

  public function wasDescribed(name) {
    return crnt.descriptions.exists(name);
  }

  public function wasSpecified(name) {
    return crnt.specifications.exists(name);
  }

  public function numSucceeded(name) {
    if(wasSpecified(name)) {
      return crnt.specifications.get(name).numSucceeded;
    }
    return 0;
  }

  public function didSucceed(name) {
    if(wasSpecified(name))
      return crnt.specifications.get(name).didSucceed;
    return false;
  }

  public function didThrow(name) {
    if(wasSpecified(name))
      return crnt.specifications.get(name).didThrow;
    return false;
  }

  public function thrown(name) {
    if(didThrow(name)) return crnt.specifications.get(name).thrown;
    throw('Yo, ${name.inspect()} did not throw!');
  }

  public function thrownLine(name) {
    if(didThrow(name)) {
      var bt = crnt.specifications.get(name).backtrace;
      switch(bt[bt.length-1]) {
        case FilePos(_, _, lineno): return lineno;
        case _: throw('Whats this!?: ${bt[bt.length-1]}');
      }
    }

    throw('Yo, ${name.inspect()} did not throw!');
  }

  // Sigh, this is so dumb.
  // Do I just not get how to do it right in Haxe, or is this really the way to do it?
  public function childrenOf(name) {
    var desc = crnt.descriptions.get(name);
    if(desc == null) throw("NO DESC: " + name);
    var children = [];
    for(child in desc.specifications.keys()) children.push(child);
    for(child in desc.descriptions.keys())   children.push(child);
    return children;
  }

  public function isPending(name) {
    if(wasSpecified(name))
      return crnt.specifications.get(name).isPending;
    return false;
  }
}
