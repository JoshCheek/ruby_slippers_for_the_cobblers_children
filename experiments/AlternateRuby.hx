import haxe.ds.StringMap;

typedef RubyObject = {
  klass:             RubyClass,
  instanceVariables: StringMap<RubyObject>,
}
typedef RubyClass = {
  > RubyObject,
  name:       String,
  superclass: Null<RubyClass>,
  methods:    StringMap<RubyObject>,
}
typedef NativeObject = {
  > RubyObject,
  nativeType: String,
  nativeData: Dynamic,
}

class AlternateRuby {
  public static function main() {
    var klass:RubyClass = {
      name:              "Class",
      klass:             null,
      instanceVariables: new StringMap(),
      superclass:        null,
      methods:           new StringMap()
    };
    klass.klass = klass;
    printClass(klass);

    var obj:RubyObject = {
      klass:             klass,
      instanceVariables: new StringMap()
    };
    printClass(obj);

    var customObj:NativeObject = {
      klass:             klass,
      instanceVariables: new StringMap(),
      nativeType:        'struct',
      nativeData:        {a: 1, b:2}
    };
    trace(sum(customObj));

    var objs = [klass, obj, customObj];
    for(o in objs.iterator())
      printClass(o);
  }

  public static function printClass(obj:RubyObject) {
    trace(obj.klass.name);
  }

  public static function sum(obj:NativeObject) {
    var a = cast(obj.nativeData.a, Int);
    var b = cast(obj.nativeData.b, Int);
    return a+b;
  }
}
