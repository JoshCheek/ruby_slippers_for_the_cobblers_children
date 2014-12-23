package ruby;

import ruby.ds.*;
import ruby.ds.objects.*;


// For now, this will become a god class,
// as it evolves, pay attention to its responsibilities so we can extract them into their own objects.
class World {
  private var world:ruby.ds.World;

  public function new(world:ruby.ds.World) {
    this.world = world;
  }

  // public function intern(name:String):RSymbol {
  //   if(!world.symbols.exists(name)) {
  //     var symbol:RSymbol = {name: name, klass: world.objectClass, ivars: new InternalMap()};
  //     world.symbols.set(name, symbol);
  //   }
  //   return world.symbols.get(name);
  // }

  public function castClass(klass:RObject):RClass {
    var tmp:Dynamic = klass;
    var typedClass:RClass = tmp;
    // or should this return null if its not a class?
    if(typedClass.imeths == null) throw("Can't cast this, it's not a class: " + inspect(klass));
    return typedClass;
  }

  public function stringLiteral(value:String):RString {
    var str:RString = {
      klass: stringClass,
      ivars: new InternalMap(),
      value: value,
    }
    objectSpace.push(str);
    return str;
  }

  // s b/c static and instance functions can't have the same name -.^
  static public function sinspect(obj:RObject):String {
    if(obj == null) return 'Haxe null';

    var klass = switch(obj) {
      case {klass: k}: k;
      case _: throw "no kass here: " + obj;
    }

    if(klass.name == 'Class') {
      var tmp:Dynamic = obj;
      var objClass:RClass = tmp;
      return objClass.name;
    } else if(klass.name == 'String') {
      var tmp:Dynamic = obj;
      var objString:RString = tmp;
      return '"'+objString.value+'"'; // will do for now
    } else {
      return "#<" + obj.klass.name + ">";
    // } else {
    //   return "" + obj; // :D
    }
  }
  public function inspect(obj:RObject):String {
    return World.sinspect(obj);
  }

  // faux attributes
  public var objectSpace(get, never):Array<RObject>;  // do I actually want to expose this directly?
  function get_objectSpace() return world.objectSpace;

  // Objects special enough to be properties
  public var              main(get, never):RObject;
  public var           rubyNil(get, never):RObject;
  public var         rubyFalse(get, never):RObject;
  public var          rubyTrue(get, never):RObject;
  public var        classClass(get, never):RClass;
  public var       stringClass(get, never):RClass;
  public var       moduleClass(get, never):RClass;
  public var       objectClass(get, never):RClass;
  public var  basicObjectClass(get, never):RClass;
  public var   toplevelBinding(get, never):RBinding;
  public var toplevelNamespace(get, never):RClass;
  public var currentExpression(get,   set):RObject;

  function              get_main() return world.main;
  function           get_rubyNil() return world.rubyNil;
  function         get_rubyFalse() return world.rubyFalse;
  function          get_rubyTrue() return world.rubyTrue;
  function        get_classClass() return world.klassClass;
  function       get_stringClass() return world.stringClass;
  function       get_moduleClass() return world.moduleClass;
  function       get_objectClass() return world.objectClass;
  function  get_basicObjectClass() return world.basicObjectClass;
  function   get_toplevelBinding() return world.toplevelBinding;
  function get_toplevelNamespace() return world.toplevelNamespace;

  function get_currentExpression()            return world.currentExpression;
  function set_currentExpression(obj:RObject) return world.currentExpression = obj;
}
