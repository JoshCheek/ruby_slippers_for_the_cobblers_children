package ruby;
import  ruby.ds.*;
import  ruby.ds.Objects;
import  ruby.ds.Errors;
import  ruby.ds.Interpreter;
using   ruby.LanguageGoBag;
using   Lambda;

class Interpreter {
  private var state:ruby.ds.Interpreter;
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


  public function pushCode(code:Ast, ?binding) {
    if(binding==null) binding = currentBinding;
    this.state.stack.push({
      ast     : code,
      binding : binding,
      state   : switch(code) {
        case Self:                  Self(Start);
        case True:                  Value(Immediate(world.rubyTrue));
        case Nil:                   Value(Immediate(world.rubyNil));
        case False:                 Value(Immediate(world.rubyFalse));
        case String(value):         Value(Function(function() return world.stringLiteral(value)));
        case Exprs(expressions):    Exprs(Crnt(0, expressions));
        case SetLvar(name, rhs):    SetLocal(FindRhs(name, rhs));
        case GetLvar(name):         GetLocal(Name(name));
        case Constant(ns, name):    GetConst(ResolveNs(ns, name));
        case Send(trg, msg, args):  Send(Start(trg, msg, args));
        case Def(name, args, body): Def(Start(name, args, body));
        case Class(Constant(ns, nm), spr, bd): OpenClass(FindNs(ns, nm)); // FIXME
        case _: throw "Unhandled AST: " + code;
      }
    });
  }

  public function evaluateAll():RObject {
    while(isInProgress) step();
    return currentExpression;
  }

  public function nextExpression():RObject {
    while(!step()) {}
    return currentExpression;
  }

  // returns true if this step evaluated to an expression
  public function step():Bool {
    if(isFinished) throw new NothingToEvaluateError("Check before evaluating!");
    var frame = state.stack.first();
    // trace("STACK SIZE: " + state.stack.length);
    // trace("CURRENT: " + frame.ast);

    switch(continueExecuting(frame)) {
      case Push(state, ast, binding):
        frame.state = state;
        pushCode(ast, binding);
        return false;
      case Pop(result):
        currentExpression = result;
        state.stack.pop();
        return true;
      case NoAction(state):
        frame.state = state;
        return false;
    }
  }

  // ----- PRIVATE -----

  inline function get_isInProgress()         return !isFinished;
  inline function get_isFinished()           return state.stack.isEmpty();
  inline function get_currentExpression()    return state.currentExpression;
  inline function set_currentExpression(val) return state.currentExpression = val;
  inline function get_stackSize()            return state.stack.length;
  inline function get_currentBinding()       return state.stack.isEmpty() ? world.toplevelBinding : state.stack.last().binding;

  function continueExecuting(sf:StackFrame):EvaluationResult {
    switch(sf.state) {
    case Send(state):
      return evalSend(sf, state);

    case Self(Start):
      return Pop(sf.binding.self);

    case Value(Immediate(result)):
      return Pop(result);

    case Value(Function(getValue)):
      return Pop(getValue());

    case Exprs(Crnt(i, exprs)):
      if(i < exprs.length) return Push(Exprs(Crnt(i+1, exprs)), exprs[i], sf.binding);
      else                 return Pop(currentExpression);

    case SetLocal(FindRhs(name, rhs)):
      return Push(SetLocal(SetLhs(name)), rhs, sf.binding);

    case SetLocal(SetLhs(name)):
      sf.binding.lvars[name] = currentExpression;
      return Pop(currentExpression);

    case GetLocal(Name(name)):
      return Pop(sf.binding.lvars[name]);

    case GetConst(ResolveNs(None, name)):
      return Pop(sf.binding.defTarget.constants[name]); // TODO: Can we push current namepace instead of having two weird paths through? (might not be able to b/c that would cause it to find the current ns as an intermediate expression, which could fuck up tests
    case GetConst(ResolveNs(nsCode, name)):
      return Push(GetConst(Get(name)), nsCode, sf.binding);
    case GetConst(Get(name)):
      var expr:Dynamic = currentExpression;
      var ns:RClass = expr;
      return Pop(ns.constants[name]);

    case Def(Start(name, args, body)):
      var klass = sf.binding.defTarget;
      klass.imeths[name] = {
        klass: world.objectClass, // FIXME
        ivars: new InternalMap(),
        name:  name,
        args:  args,
        body:  Ruby(body),
      }
      return Pop(world.intern(name));
    case OpenClass(FindNs(None, name)):
      return NoAction(OpenClass(Open(sf.binding.defTarget, name)));
    case OpenClass(Open(ns, name)):
      if(ns.constants[name] == null) {
        var klass:RClass = {
          name:       name,
          klass:      world.classClass,
          superclass: world.objectClass, // FIXME
          ivars:      new InternalMap(),
          imeths:     new InternalMap(),
          constants:  new InternalMap(),
        };
        ns.constants[name] = klass;
      }
      return Pop(world.rubyNil); // FIXME

    case OpenClass(state):
      throw "No tests on this yet: " + state;
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
      case Start(None, msg, argsCode):
        currentExpression = sf.binding.self;
        noAction(GetTarget(msg, argsCode));

      case Start(targetCode, msg, argsCode):
        push(GetTarget(msg, argsCode), targetCode);

      case GetTarget(msg, argsCode):
        var target = currentExpression;
        if(argsCode.length == 0)
          noAction(Invoke(target, msg, []));
        else
          push(EvalArgs(target, msg, argsCode, []), argsCode[0]);

      case EvalArgs(trg, msg, argAsts, argObjs):
        throw("No tests should reach this yet!");
        argObjs.push(currentExpression);
        if(argAsts.length < argObjs.length)
          noAction(Invoke(trg, msg, argObjs));
        else
          push(EvalArgs(trg, msg, argAsts, argObjs),
               argAsts[argObjs.length]);

      case Invoke(target, message, args):
        var klass = target.klass;
        while(klass != null && klass.imeths[message] == null)
          klass = klass.superclass;

        var meth  = null;
        if(klass == null) throw "HAVEN'T IMPLEMENTED METHOD MISSING YET!";
        else              meth = klass.imeths[message];

        // make the new binding
        var bnd:RBinding = {
          klass:     world.objectClass, // FIXME: should be Binding, not Object!
          ivars:     new InternalMap(),
          self:      target,
          defTarget: target.klass,
          lvars:     new InternalMap(),
        };

        // TODO: set the args in the binding
        if(args.length > 0) throw "NEED TO SET ARGS!";

        // execute the method (if it is code, push it on the stack and evaluate it)
        // if it's internal, evaluate it directly
        switch(meth.body) {
          case(Ruby(ast)):    Push(Send(End), ast, bnd);
          case(Internal(fn)): Pop(fn(bnd, world));
        }

      case End:
        Pop(currentExpression);

      case _:
        throw "Unhandled: " + state;
    }
  }
}
