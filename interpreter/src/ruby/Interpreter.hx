package ruby;
import ruby.ds.*;
import ruby.ds.objects.*;
import ruby.ds.Errors;
using ruby.LanguageGoBag;
using Lambda;

class Interpreter {
  private var state:ruby.ds.Interpreter;
  private var world:ruby.World;

  public function new(state:ruby.ds.Interpreter) {
    this.state = state;
    this.world = new ruby.World(state.world);
  }

  public var stackSize(get, never):Int;
  function get_stackSize() return state.stack.length;

  public var currentBinding(get, never):RBinding;
  function get_currentBinding() {
    if(state.stack.isEmpty()) return world.toplevelBinding;
    return state.stack.last().binding;
  }

  public function getLocal(name:String):RObject {
    var val = currentBinding.lvars[name];
    if(val!=null) return val;
    var readableKeys = [for(k in currentBinding.lvars.keys()) k];
    throw "No local variable " + name + ", only has: " + readableKeys;
  }

  public function setLocal(name:String, value:RObject):RObject {
    currentBinding.lvars[name] = value;
    return value;
  }


  public function pushCode(code:Ast, ?binding) {
    if(binding==null) binding = currentBinding;
    this.state.stack.push({
      ast     : code,
      binding : binding,
      state   : switch(code) {
        case Self:                 Self;
        case True:                 Value(world.rubyTrue);
        case Nil:                  Value(world.rubyNil);
        case False:                Value(world.rubyFalse);
        case String(value):        PendingValue(function() return world.stringLiteral(value));
        case Exprs(expressions):   Expressions({crnt:0, expressions:expressions});
        case SetLvar(name, rhs):   SetLocal(FindRhs(name, rhs));
        case GetLvar(name):        GetLocal({name:name});
        case Constant(ns, name):   GetConst({state:"ns", name:name, nsCode:ns});
        case Send(trg, msg, args): Send({state:"initial", targetCode:trg, target:null, message:msg, argsCode:args, args:[]});
        case Class(Constant(ns, nm), superclass, body):
          OpenClass({state:"ns", name:nm, nsCode:ns, ns:null, klass:null});
        case _: throw "Unhandled AST: " + code;
      }
    });
  }

  public function nextExpression():RObject {
    while(!step()) {}
    return world.currentExpression;
  }

  // returns true if this step evaluated to an expression
  public function step():Bool {
    if(isFinished()) throw new NothingToEvaluateError("Check before evaluating!");
    var frame = state.stack.first();
    // trace("STACK SIZE: " + state.stack.length);
    // trace("CURRENT: " + frame.ast);

    switch(continueExecuting(frame)) {
      case Push(state, ast, binding):
        frame.state = state;
        pushCode(ast, binding);
        return false;
      case Pop(result):
        world.currentExpression = result;
        state.stack.pop();
        return true;
      case NoAction(state):
        frame.state = state;
        return false;
    }
  }

  public function isInProgress() {
    return !isFinished();
  }

  public function isFinished() {
    return state.stack.isEmpty();
  }

  public function evaluateAll():RObject {
    while(isInProgress()) step();
    return world.currentExpression;
  }

  // ----- PRIVATE -----
  function currentExpression():RObject {
    return world.currentExpression;
  }

  function continueExecuting(sf:ruby.ds.Interpreter.StackFrame):ruby.ds.Interpreter.EvaluationResult {
    switch(sf.state) {

    // get target
    case Send(s={state:"initial", targetCode:targetCode}):
      s.state = "evaluatedTarget";
    return Push(Send(s), targetCode, sf.binding);

    // get args
    case Send(s={state:"evaluatedTarget", args:args, argsCode:argsCode}):
      s.target = currentExpression();
      if(args.length < argsCode.length) {
        s.state = "evaluatingArgs";
        return Push(Send(s), argsCode[args.length], sf.binding);
      } else {
        s.state = "evaluatedArgs";
        return NoAction(Send(s));
      }
    case(Send(s={state:"evaluatingArgs", args:args, argsCode:argsCode})):
      args.push(currentExpression());
      if(args.length < argsCode.length) {
        return Push(Send(s), argsCode[args.length], sf.binding);
      } else {
        s.state = "evaluatedArgs";
        return NoAction(Send(s));
      }
    // find method
    case(Send(s={state:"evaluatedArgs", target:target, message:message, args:args})):
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
        case(Ruby(ast)):    return Push(Send(s), ast, bnd);
        case(Internal(fn)): return Pop(fn(bnd, world));
      }

    case Self:
      return Pop(sf.binding.self);

    case Value(result):
      return Pop(result);

    case PendingValue(getValue):
      return Pop(getValue());

    case Expressions(state):
      if(state.crnt < state.expressions.length) {
        return Push(
          Expressions(state),
          state.expressions[state.crnt++],
          sf.binding
        );
      }
      if(state.crnt == state.expressions.length) {
        return Pop(currentExpression());
      } else {
        throw "SHOULDN'T HAPPEN!";
      }

    case SetLocal(FindRhs(name, rhs)):
      return Push(SetLocal(SetLhs(name)), rhs, sf.binding);

    case SetLocal(SetLhs(name)):
      sf.binding.lvars[name] = currentExpression();
      return Pop(currentExpression());

    case GetLocal({name:name}):
      return Pop(sf.binding.lvars[name]);

    case GetConst({state:"ns", nsCode:None, name:name}):
      return Pop(sf.binding.defTarget.constants[name]);
    case GetConst(state={state:"ns", nsCode:code, name:name}):
      state.state = 'get';
      return Push(GetConst(state), code, sf.binding);
    case GetConst({state: "get", nsCode:ast, name:name}):
      return Pop(currentExpression());
    case GetConst({state: s}):
      throw "Shouldn't have gotten here, what is state?: " + s;

    case OpenClass(state={state:"ns", nsCode:None, name:name}):
      state.state = "def";
      state.ns = sf.binding.defTarget;
      return NoAction(OpenClass(state));
    case OpenClass(state={state:"ns", nsCode:ns, name:name}):
      throw "No tests on this yet";
      state.state = "get";
      return Push(OpenClass(state), ns, sf.binding);
    case OpenClass(state={state:"get"}):
      throw "No tests on this yet";
      state.state = "def";
      var expr:Dynamic = currentExpression();
      state.ns = expr;
      return NoAction(OpenClass(state));
    case OpenClass(state={state:"def", name:name, ns:ns}):
      if(ns.constants[name] == null) {
        var klass:RClass = {
          name:       name,
          klass:      world.classClass,
          superclass: world.objectClass,
          ivars:      new InternalMap(),
          imeths:     new InternalMap(),
          constants:  new InternalMap(),
        };
        ns.constants[name] = klass;
      }
      return Pop(world.rubyNil);
    case OpenClass(_):
      throw "Shouldn't have gotten here, what is state?: " + sf.state;

    case Send(_):
      throw "haven't moved this yet";
    }
  }

  // // updates current evaluation, updates current expression if relevant;
  // private function setEval(evaluation:EvaluationState):EvaluationState {
  //   switch(evaluation) {
  //     case Evaluated(obj):
  //       world.currentExpression = obj;
  //       _evaluationFinished = true; // TODO: this name is terrible! there's a Finished value in EvaluationState, but we're actually talking about when an evaluation resolves to an object that a user could see
  //     case EvaluationList(Cons(crnt, _)):
  //       setEval(crnt); // child might have finished (FIXME: we're doing 2 responsibilities here, setting eval and setting currentExpression, which is why lines like this are necessary and confusing)
  //     case SetLocal(_, value):
  //       setEval(value);
  //     case _:
  //       _evaluationFinished = false;
  //   }
  //   currentEvaluation = evaluation;
  //   return evaluation;
  // }


  // private function continueEvaluating(toEval:EvaluationState) {
  //   switch(toEval) {
  //     // case Send(Evaluated(target), message):              throw "need to actually do shit now";
  //     // case Send(target, message):                         return Send(continueEvaluating(target), message);
  //     case EvaluationList(Cons(Evaluated(obj), ListEnd)): return Evaluated(obj);
  //     case EvaluationList(Cons(Evaluated(obj), rest)):    return EvaluationList(rest);
  //     case EvaluationList(Cons(current, rest)):           return EvaluationList(Cons(continueEvaluating(current), rest));
  //     case GetLocal(name):                                return Evaluated(world.getLocal(name));
  //     case SetLocal(name, Evaluated(value)):              return Evaluated(world.setLocal(name, value));
  //     case SetLocal(name, value):                         return SetLocal(name, continueEvaluating(value));
  //     case Evaluated(_):                                  return Finished;
  //     case Unevaluated(ast):                              return astToEvaluation(ast);
  //     case ConstantName(Lookup(ImplicitNamespace, name)):
  //       // Where is it supposed to look these up? this is one thing I don't fully understand about Ruby :/
  //       return Evaluated(world.toplevelNamespace.constants[name]);

  //     case ConstantName(Lookup(namespace, name)): throw "multiple namespaces not yet handled!";
  //     case Finished:                              throw new NothingToEvaluateError("Check before evaluating!");

  //     // fucking ADTS are stupid, even splitting out those values into their own types doesn't prevent stupid shit like this
  //     case ConstantName(ImplicitNamespace): throw "This shouldn't be possible!";
  //     case EvaluationList(ListEnd):         throw "This shouldn't be possible!";
  //   }
  // }

  // private function astToEvaluation(ast:Ast):EvaluationState {
  //   switch(ast) {
  //     case AstSend(target, message, args): return Evaluated(world.stringLiteral("SEND NOT ACTUALL IMPLEMENTED")); // Send(astToEvaluation(target), message);
  //     case AstConstant(namespace, name):   // FIXME: not handling namespace properly
  //                                          return ConstantName(Lookup(ImplicitNamespace, name));
  //     case AstFalse:                       return Evaluated(world.rubyFalse);
  //     case AstTrue:                        return Evaluated(world.rubyTrue);
  //     case AstNil:                         return Evaluated(world.rubyNil);
  //     case AstString(value):               return Evaluated(world.stringLiteral(value));
  //     case AstExpressions(exprs):
  //       return
  //         if(exprs.length == 0)      Evaluated(world.rubyNil);
  //         else if(exprs.length == 1) EvaluationList(Cons(astToEvaluation(exprs[0]), ListEnd));
  //         else                       EvaluationList(exprs
  //                                      .fromEnd()
  //                                      .fold(
  //                                        function(el, lst) return Cons(astToEvaluation(el), lst),
  //                                        ListEnd
  //                                      ));
  //     case AstGetLocalVariable(name):        return GetLocal(name);
  //     case AstSetLocalVariable(name, value): return SetLocal(name, astToEvaluation(value));
  //     case _:
  //       throw "Unhandled: " + ast;
  //   }
  // }
}
