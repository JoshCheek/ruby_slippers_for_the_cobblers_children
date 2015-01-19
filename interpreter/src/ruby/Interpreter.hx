package ruby;
import  ruby.ds.*;
import  ruby.ds.Objects;
import  ruby.ds.Errors;
import  ruby.ds.Interpreter;
using   ruby.LanguageGoBag;
using   Lambda;

class Interpreter {
  public  var state:ruby.ds.Interpreter;
  private var world:ruby.World;

  public var isFinished        (get, never):Bool;
  public var isInProgress      (get, never):Bool;
  public var stackSize         (get, never):Int;
  public var currentBinding    (get, never):RBinding;
  public var currentExpression (get,   set):RObject; // set becomes public, is there a private for this?

  public function new(world:ruby.World, state:ruby.ds.Interpreter) {
    this.world = world;
    this.state = state;
  }

  public function getLocal(name:String):RObject { // do I actually want this public?
    var val = currentBinding.lvars[name];
    if(val!=null) return val;
    var readableKeys = [for(k in currentBinding.lvars.keys()) k];
    throw "No local variable " + name + ", only has: " + readableKeys;
  }

  public function setLocal(name:String, value:RObject):RObject { // do I actually want this public?
    currentBinding.lvars[name] = value;
    return value;
  }


  public function pushCode(code:ExecutionState, ?binding):StackFrame {
    if(code==null) throw new Errors("Code to evaluate was null!");
    if(binding==null) binding = currentBinding;
    var stackFrame = {binding:binding, state:code};
    this.state.stack.push(stackFrame);
    return stackFrame;
  }

  public function evaluateAll():RObject {
    while(isInProgress) step();
    return currentExpression;
  }

  public function nextExpression():RObject {
    while(true) {
      switch(step()) {
        case Pop(obj): return obj;
        case _: /*no op*/
      }
    }
  }

  // returns true if this step evaluated to an expression
  public function step():EvaluationResult {
    if(isFinished) throw new NothingToEvaluateError("Check before evaluating!");
    var frame  = state.stack.first();
    var result = continueExecuting(frame);

    switch(result) {
      case Push(state, ast, binding):
        frame.state = state;
        var frame = pushCode(ast, binding);
        result = Push(state, ast, frame.binding);
      case Pop(obj):
        currentExpression = obj;
        state.stack.pop();
      case NoAction(state):
        frame.state = state;
    }
    return result;
  }

  // ----- PRIVATE -----

  inline function get_isInProgress()         return !isFinished;
  inline function get_isFinished()           return state.stack.isEmpty();
  inline function get_currentExpression()    return state.currentExpression;
  inline function set_currentExpression(val) return state.currentExpression = val;
  inline function get_stackSize()            return state.stack.length;
  inline function get_currentBinding()       return state.stack.isEmpty() ? world.toplevelBinding : state.stack.last().binding;

  function continueExecuting(sf:StackFrame):EvaluationResult {
    return switch(sf.state) {
    case Send(state):
      evalSend(sf, state);

    case Self:  Pop(sf.binding.self);
    case True:  Pop(world.rubyTrue);
    case False: Pop(world.rubyFalse);
    case Nil:   Pop(world.rubyNil);
    case String(val): Pop(world.stringLiteral(val));
    case Default:
      var iter = this.state.stack.iterator();
      iter.next();
      var state = iter.next().state;
      throw("SHOULDN'T HIT THIS! FIRST STACK IS: " + state);

    case Value(Immediate(result)):
      Pop(result);

    case Value(Function(getValue)):
      Pop(getValue());

    case Exprs(Start(exprs)):
      NoAction(Exprs(Crnt(0, exprs)));
    case Exprs(Crnt(i, exprs)):
      if(i < exprs.length) Push(Exprs(Crnt(i+1, exprs)), exprs[i], sf.binding);
      else                 Pop(currentExpression);

    case SetLvar(FindRhs(name, rhs)):
      Push(SetLvar(SetLhs(name)), rhs, sf.binding);
    case SetLvar(SetLhs(name)):
      sf.binding.lvars[name] = currentExpression;
      Pop(currentExpression);
    case GetLvar(Name(name)):
      Pop(sf.binding.lvars[name]);

    case GetIvar(Name(name)):
      var value = sf.binding.self.ivars[name];
      if(value == null) value = world.rubyNil;
      Pop(value);

    case SetIvar(FindRhs(name, rhs)):
      Push(SetIvar(SetLhs(name)), rhs, sf.binding);
    case SetIvar(SetLhs(name)):
      sf.binding.self.ivars[name] = currentExpression;
      Pop(currentExpression);

    case Const(GetNs(Default, name)):
      Pop(sf.binding.defTarget.constants[name]); // TODO: Can we push current namepace instead of having two weird paths through? (might not be able to b/c that would cause it to find the current ns as an intermediate expression, which could fuck up tests
    case Const(GetNs(nsCode, name)):
      Push(Const(Get(name)), nsCode, sf.binding);
    case Const(Get(name)):
      var expr:Dynamic = currentExpression;
      var ns:RClass = expr;
      Pop(ns.constants[name]);

    case Def(Start(name, args, body)):
      var klass:RClass = sf.binding.defTarget;
      var meth:RMethod = new RMethod();
      meth.klass = world.objectClass; // FIXME
      meth.ivars = new InternalMap();
      meth.name  = name;
      meth.args  = args;
      meth.body  = Ruby(body);
      klass.imeths[name] = meth;
      Pop(world.intern(name));

    // TODO: extract OpenClass into its own method
    case OpenClass(GetNs(Const(GetNs(Default, name)), superclassCode, body)):
      currentExpression = sf.binding.defTarget;
      return NoAction(OpenClass(GetSpr(name, superclassCode, body)));
    case OpenClass(GetNs(Const(GetNs(ns, name)), superclassCode, body)):
      return Push(OpenClass(GetSpr(name, superclassCode, body)), ns, sf.binding);
    case OpenClass(GetSpr(name, Default, body)):
      var tmp:Dynamic = currentExpression;
      var ns:RClass = tmp;
      currentExpression = world.objectClass;
      return NoAction(OpenClass(Open(ns, name, body)));
    case OpenClass(Open(ns, name, body)):
      var tmp:Dynamic = currentExpression;
      var sprClass:RClass = tmp;
      var tmp:Dynamic = ns.constants[name];
      var klass:RClass = null;
      if(ns.constants[name] == null) {
        klass = new RClass();
        klass.name       = name;
        klass.klass      = world.classClass;
        klass.superclass = sprClass;
        klass.ivars      = new InternalMap();
        klass.imeths     = new InternalMap();
        klass.constants  = new InternalMap();
        ns.constants[name] = klass;
      } else {
        klass = world.castClass(ns.constants[name]);
      }
      return NoAction(OpenClass(Body(klass, body)));
    case OpenClass(Body(klass, Default)):
      return Pop(world.rubyNil);
    case OpenClass(Body(klass, body)):
      var bnd = new RBinding();
      bnd.klass     = world.objectClass; // FIXME: should be Binding, not Object!
      bnd.ivars     = new InternalMap();
      bnd.self      = klass;
      bnd.defTarget = klass;
      bnd.lvars     = new InternalMap();
      return Push(OpenClass(Finished), body, bnd);
    case OpenClass(Finished):
      return Pop(currentExpression);
    case OpenClass(x):
      throw "FIX OpenClass: " + x;
    case Float(_) | Integer(_):
      throw "UNHANDLED: " + sf.state;
    }
  }


  /* Could be rendered in much more granularity, someting like:
    Start             -> (GetImplicitTarget | EvalTarget)
    GetImplicitTarget -> EvalArgs
    EvalTarget        -> EvalArgs
    EvalArgs          -> (PushArg | FindMethod)
    PushArg           -> PopArg
    PopArg            -> (PushArg | FindMethod)
    StartMethodLookup -> GetClass
    GetClass          -> MethodLookup
    MethodLookup      -> (MethodMissing | FoundMethod | SetSuperclass)
    SetSuperclass     -> MethodLookup
    MethodMissing     -> ??
    FoundMethod       -> CreateBinding
    CreateBinding     -> SetLocals
    SetLocals         -> (... | InvokeMethod)
    InvokeMethod      -> Finished
    End
  */
  function evalSend(sf:StackFrame, state:SendState):EvaluationResult {
    inline function push(state, code) return Push(Send(state), code, sf.binding);
    inline function noAction(state)   return NoAction(Send(state));

    return switch(state) {
      case Start(Default, msg, argCodes):
        currentExpression = sf.binding.self;
        noAction(GetTarget(msg, argCodes));

      case Start(targetCode, msg, argCodes):
        push(GetTarget(msg, argCodes), targetCode);

      case GetTarget(msg, argCodes):
        var target = currentExpression;
        if(argCodes.length == 0) noAction(Invoke(target, msg, []));
        else                      push(EvalArgs(target, msg, argCodes, []), argCodes[0]);

      case EvalArgs(trg, msg, argCodes, args):
        args = args.concat([currentExpression]); // concat returns a new array
        if(argCodes.length <= args.length) noAction(Invoke(trg, msg, args));
        else                               push(EvalArgs(trg, msg, argCodes, args), argCodes[argCodes.length]);

      case Invoke(target, message, args):
        // trace(target.klass.name+'#'+message);
        var klass = target.klass;
        while(klass != null && klass.imeths[message] == null)
          klass = klass.superclass;

        var meth  = null;
        if(klass == null) throw "HAVEN'T IMPLEMENTED METHOD MISSING YET! "+target.klass.name+"#"+message;
        else              meth = klass.imeths[message];

        // make the new binding
        var bnd:RBinding = new RBinding();
        bnd.klass     = world.objectClass; // FIXME: should be Binding, not Object!
        bnd.ivars     = new InternalMap();
        bnd.self      = target;
        bnd.defTarget = target.klass;
        bnd.lvars     = new InternalMap();

        // Set the args in the binding
        var argsDup = [for(a in args) a];
        argsDup.reverse;

        for(param in meth.args) {
          switch(param) {
            case Required(name):
              bnd.lvars[name] = args.pop();
            case Rest(name):
              var internalRestArgs:Array<RObject> = [];
              var restArgs:RArray = new RArray();
              restArgs.klass    = world.objectClass; // FIXME!
              restArgs.ivars    = new InternalMap();
              restArgs.elements = [];

              while(argsDup.length != 0)
                restArgs.elements.push(argsDup.pop());
              bnd.lvars[name] = restArgs;
          }
        }

        // execute the method (if it is code, push it on the stack and evaluate it)
        // if it's internal, evaluate it directly
        switch(meth.body) {
          case(Ruby(Default)): Pop(world.rubyNil);
          case(Ruby(ast)):     Push(Send(End), ast, bnd);
          case(Internal(fn)):  fn(bnd, world);
        }

      // case ReturnInternal(callback):
      //   Push(CallIntoInternal(callback), code, bnd);
      // case CallIntoInternal(callback):
      //   callback(currentExpression);
      // case EndCalculated(toReturn);
      //   currentExpression = toReturn;
      //   noAction(END);

      case End:
        Pop(currentExpression);

      case EndInternal(returnValue):
        Pop(returnValue);

      case _:
        throw "Unhandled: " + state;
    }
  }
}
