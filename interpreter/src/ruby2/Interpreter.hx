package ruby2;
import ruby2.ast.*;
import ruby2.World;
import ruby2.Objects;

import Inspect;

class StackFrame<T> {
  public var binding                : RBinding;
  public var ast                    : Ast;
  public var evaluation             : Evaluation<T>;
  public var returned               : RObject;
  public var self      (get, never) : RObject;
  public var defTarget (get, never) : RClass;
  public var lvars     (get, never) : InternalMap<RObject>;

  public function new(attrs) {
    this.binding    = attrs.binding;
    this.ast        = attrs.ast;
    this.evaluation = attrs.evaluation;
    this.returned   = attrs.returned;
  }

  public function inspect() {
    return 'new StackFrame({binding: ${World.inspectObj(binding)}}, ast: ${Inspect.call(ast)}, evaluation: ${Inspect.call(evaluation)}, returned: ${Inspect.call(returned)}})';
  }

  // -----------------
  inline function get_self()      return binding.self;
  inline function get_defTarget() return binding.defTarget;
  inline function get_lvars()     return binding.lvars;
}

typedef Evaluation<T> = {
  public var name         : String;
  public var description  : String;
  public var states       : haxe.ds.EnumValueMap<T, EvaluationState<T>>;
  public var currentState : EvaluationState<T>;
}

typedef EvaluationState<T> = {
  public var index        : Int;
  public var instructions : Array<Instruction>;
}

// as in a "null object" -- perhaps rename to noop or NilLoop might be nice
enum NullEvaluationState {
  Null;
}

enum NilEvaluationState {
  EvaluateNil;
}

enum TrueEvaluatoinState {
  EvaluateTrue;
}

enum FalseEvaluatoinState {
  EvaluateFalse;
}

enum ExprsEvaluationState {
  PushExpressions;
  Return;
}

enum Instruction {
  Pop;
  PushNil;
  PushTrue;
  PushFalse;
  EvalAst(ast:Ast);
  Emit;
  AdvanceState<T>(stateType:T);
  Return;
  PushReturned;
}


class Compile {
  public static function nullEvaluation():Evaluation<NullEvaluationState> {
    var states = [
      Null => {
        index: 0,
        instructions: [PushNil, Emit, Pop, AdvanceState(Null)],
      }
    ];
    return {
      name:         'NullEvaluation',
      description:  'Returns nil, forever',
      states:       states,
      currentState: states.get(Null),
    }
  }

  // I honestly do not understand why this has to be dynamic instead of Enum<Dynamic>
  // or why the type system doesn't allow me to say "one of these values"
  public static function call<T>(ast:Ast):Evaluation<Dynamic> {
    if(ast.isTrue) {
      var states = [
        EvaluateTrue => { index: 0, instructions: [PushTrue, Return] }
      ];
      return {
        name:         'TrueEvaluation',
        description:  'Evaluates to true',
        states:       states,
        currentState: states.get(EvaluateTrue),
      }


    } else if(ast.isFalse) {
      var states = [
        EvaluateFalse => { index: 0, instructions: [PushFalse, Return] }
      ];
      return {
        name:         'TrueEvaluation',
        description:  'Evaluates to false',
        states:       states,
        currentState: states.get(EvaluateFalse),
      }


    } else if(ast.isNil) {
      var states = [
        EvaluateNil => { index: 0, instructions: [PushNil, Return] }
      ];
      return {
        name:         'TrueEvaluation',
        description:  'Evaluates to nil',
        states:       states,
        currentState: states.get(EvaluateNil),
      }


    } else if(ast.isExprs) {
      var exprsAst        = ast.toExprs();
      var pushExpressions = [for(i in 0...exprsAst.length) EvalAst(exprsAst.get(i))];
      pushExpressions.push(AdvanceState(ExprsEvaluationState.Return));
      var states = [
        PushExpressions => {index: 0, instructions: pushExpressions},
        Return          => {index: 0, instructions: [PushReturned, Return]},
      ];
      return {
        name:         'ExprsEvaluation',
        description:  'Evaluates a list of expressions',
        states:       states,
        currentState: states.get(PushExpressions),
      }


    } else {
      throw('NO COMPILATION INSTRUCTION YET FOR ${ast.inspect()}');
    }
  }
}


class Interpreter {
  public var world       : World;
  public var stackFrames : Stack<StackFrame<Dynamic>>;
  public var valueStack  : Stack<RObject>;

  public function new(world, ast) {
    this.world             = world;
    this.currentExpression = world.rNil;
    this.valueStack        = new Stack();

    this.stackFrames = new Stack();
    stackFrames.push(new StackFrame({
      binding:    world.rToplevelBinding,
      ast:        new DefaultAst({begin_loc: -1, end_loc: -1}),
      evaluation: Compile.nullEvaluation(),
      returned:   world.rNil,
    }));
    stackFrames.push(new StackFrame({
      binding:    world.rToplevelBinding, // technically wrong, should be a binding in this one's environment
      ast:        ast,
      evaluation: Compile.call(ast),
      returned:   world.rNil,
    }));
  }

  public var currentExpression(default, null):RObject;

  public function nextExpression():RObject {
    var frame      = stackFrames.peek;
    // trace("!!!!!!!!!!!!!!!!!");
    // trace('FRAME: ${Inspect.call(frame)}');
    // trace("!!!!!!!!!!!!!!!!!");
    var evaluation = frame.evaluation;
    var state      = evaluation.currentState;

    // trace("");
    // trace("-----------------");

    var foundExpression = false;
    while(!foundExpression) {
      // trace('  ${state}');

      switch(state.instructions[state.index++]) {
        case PushNil:
          valueStack.push(world.rNil);
        case PushTrue:
          valueStack.push(world.rTrue);
        case PushFalse:
          valueStack.push(world.rFalse);
        case EvalAst(ast):
          stackFrames.push(new StackFrame({
            binding:    stackFrames.peek.binding,
            ast:        ast,
            evaluation: Compile.call(ast),
            returned:   world.rNil,
          }));
        case PushReturned:
          valueStack.push(stackFrames.peek.returned);
        case Return:
          // trace('\033[34m[POPPING ${Inspect.call(stackFrames.peek)}\033[39m');
          stackFrames.pop();
          currentExpression         = valueStack.pop();
          stackFrames.peek.returned = currentExpression;
          foundExpression           = true;
          state.index               = 0;
        case Emit:
          currentExpression = valueStack.peek;
          foundExpression   = true;
        case AdvanceState(nextState):
          state.index             = 0;
          state                   = evaluation.states.get(nextState);
          evaluation.currentState = state;
        case Pop:
          valueStack.pop();
      }
      // case GotoState(nextState):
      //   evaluation.currentState = evaluation.states[nextState];
      //   evaluation.currentState.index = 0;
    }

    return currentExpression;
  }

  // ----- private -----
}
