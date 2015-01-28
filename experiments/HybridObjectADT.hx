enum ConcreteType { A; B; }

@:forward(t)
abstract Conjunction(Concrete) {
  public function new(t:ConcreteType) {
    this = Concrete.factory(t);
  }

  @:to public function toConcreteA():ConcreteA return castTo(A);
  @:to public function toConcreteB():ConcreteB return castTo(B);

  function castTo(concreteType:ConcreteType):Dynamic {
    switch(this.t) {
      case concreteType:
        var self:Dynamic = this;
        return self;
    }
    throw('TYPES DO NOT MATCH. EXPECTED ${concreteType}, BUT WAS ${this.t}');
  }
}

class Concrete {
  public var t:ConcreteType;
  public static function factory(t:ConcreteType):Concrete {
    switch(t) {
      case A: return new ConcreteA(t);
      case B: return new ConcreteB(t);
    }
  }
  public function new(t) this.t = t;
}

class ConcreteA extends Concrete {
  public var msg="i am a";
}

class ConcreteB extends Concrete {
  public var msg="i am b";
}

class HybridObjectADT {
  public static function main() {
    var a = new Conjunction(A);
    var ca:ConcreteA = a;
    trace(ca.msg);

    var b = new Conjunction(B);
    var cb:ConcreteB = b;
    trace(cb.msg);

    var bfail = new Conjunction(B);
    var cbfail:ConcreteA = bfail;
    trace(cbfail.msg);
  }
}

