package spaceCadet;
import spaceCadet.SpaceCadet;

typedef SpecState = {
  numSucceeded : Int,
  didSucceed   : Bool,
  isPending    : Bool
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
  private var crnt = new DescData();
  public function new() {}

  public function declareSpec(name, run) {
    var result = {numSucceeded:0, didSucceed:true, isPending:false};
    crnt.specifications.set(name, result);

    var onSuccess = function(msg) {
      result.numSucceeded++;
    }

    var onFailure = function(msg) {
      result.didSucceed = false;
      throw new TestFinished();
    }

    var onPending = function(?msg) {
      result.isPending = true;
      throw new TestFinished();
    }

    try {
      run(onSuccess, onFailure, onPending);
    } catch(_:TestFinished) {}
  }

  public function declareDescription(name, run) {
    var oldDesc = this.crnt;
    var data    = new DescData();
    this.crnt   = data;
    oldDesc.descriptions.set(name, data);
    run();
    this.crnt   = oldDesc;
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
