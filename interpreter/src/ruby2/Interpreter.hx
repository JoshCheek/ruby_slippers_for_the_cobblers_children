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

enum Instruction {
  PushNil;
  PushTrue;
  Return;
  EmitValue;
  AdvanceState<T>(stateType:T);
}

enum NullEvaluationState {
  Null;
}

enum TrueEvaluatoinState {
  EvaluateTrue;
}

class Compile {
  public static function nullEvaluation():Evaluation<NullEvaluationState> {
    var states = [
      Null => {
        index: 0,
        instructions: [PushNil, EmitValue, AdvanceState(Null)],
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
    } else {
      throw('NO COMPILATION INSTRUCTION YET FOR ${ast.inspect()}');
    }
  }
}


class Interpreter {
  var world       : World;
  var stackFrames : Stack<StackFrame<Dynamic>>;
  var valueStack  : Stack<RObject>;

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
    var evaluation = frame.evaluation;
    var state      = evaluation.currentState;

    var foundExpression = false;
    while(!foundExpression) {
      switch(state.instructions[state.index++]) {
        case PushTrue:
          valueStack.push(world.rTrue);
        case Return:
          currentExpression = valueStack.pop();
          foundExpression   = true;
        case i:
          trace(Inspect.call(i));
        // case GotoState(nextState):
        //   evaluation.currentState = evaluation.states[nextState];
        //   evaluation.currentState.index = 0;
      }
    }

    return currentExpression;
  }

  // ----- private -----
}
