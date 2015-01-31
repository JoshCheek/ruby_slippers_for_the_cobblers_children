package ruby3;
import ruby3.ast.*;
import ruby3.World;
import ruby3.Objects;

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
    return 'new StackFrame({binding: ..., ast: ${Inspect.call(ast)}, evaluation: ..., returned: ${Inspect.call(returned)}})';
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

enum SelfEvaluatoinState {
  EvaluateSelf;
}

enum ExprsEvaluationState {
  PushExpressions;
  Return;
}

enum StringEvaluationState {
  CreateString;
  ThenReturn; // god, if I name this Return, it blows the fuck up :(
}

enum Instruction {
  Pop;
  PushNil;
  PushTrue;
  PushFalse;
  PushSelf;
  PushClassString;
  PushData(data:Dynamic);
  AllocateObject(structure:Class<RObject>);
  SetAttribute(name:String);
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
        name:         'FalseEvaluation',
        description:  'Evaluates to false',
        states:       states,
        currentState: states.get(EvaluateFalse),
      }



    } else if(ast.isNil) {
      var states = [
        EvaluateNil => { index: 0, instructions: [PushNil, Return] }
      ];
      return {
        name:         'NilEvaluation',
        description:  'Evaluates to nil',
        states:       states,
        currentState: states.get(EvaluateNil),
      }


    } else if(ast.isSelf) {
      var states = [
        EvaluateSelf => { index: 0, instructions: [PushSelf, Return] }
      ];
      return {
        name:         'SelfEvaluation',
        description:  'Evaluates to self',
        states:       states,
        currentState: states.get(EvaluateSelf),
      }


    } else if(ast.isString) {
      // trace('STRING VALUE: ${Inspect.call(ast.toString().value)}');
      var states = [
        CreateString => { index: 0, instructions: [
          PushData(ast.toString().value),
          PushClassString,
          AllocateObject(RString),
          SetAttribute("value"),
          AdvanceState(ThenReturn),
        ] },
        ThenReturn => { index: 0, instructions: [Instruction.Return] },
      ];
      return {
        name:         'StringEvaluation',
        description:  'Evaluates a string literal',
        states:       states,
        currentState: states.get(CreateString),
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


// it's so fucking stupid that we need this
enum ValueStackType {
  Obj(_:RObject);
  Data(_:Dynamic);
}

class Interpreter {
  public var world       : World;
  public var stackFrames : Stack<StackFrame<Dynamic>>;
  public var valueStack  : Stack<ValueStackType>;

  public var currentExpression (default, null):RObject;
  public var isInProgress      (default, null):Bool;

  public function new(world, ast) {
    this.world             = world;
    this.currentExpression = world.rNil;
    this.valueStack        = new Stack();
    this.isInProgress      = true;

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

  public function nextExpression():RObject {
    var foundExpression = false;
    while(!foundExpression) {
      var frame       = stackFrames.peek;
      var evaluation  = frame.evaluation;
      var state       = evaluation.currentState;
      var instruction = state.instructions[state.index];
      // trace('  ${state}\033[45m/\033[49m${Inspect.call(instruction)}');
      state.index++;

      switch(instruction) {
        case Pop:
          valueStack.pop();
        case PushNil:
          valueStack.push(Obj(world.rNil));
        case PushTrue:
          valueStack.push(Obj(world.rTrue));
        case PushFalse:
          valueStack.push(Obj(world.rFalse));
        case PushSelf:
          valueStack.push(Obj(frame.self));
        case PushClassString:
          valueStack.push(Obj(world.rcString));
        case PushData(data):
          valueStack.push(Data(data));
        case AllocateObject(structure):
          var instance = Type.createInstance(structure, []);
          switch(valueStack.pop()) {
            case Obj(klass):
              instance.klass = cast(klass); // FIXME -- how about pop methods for each of these to handle the stupid fkn enum. Then we add a type for Class, and do popClass. If you do popObject, that will work for either a Class or an Obj
              instance.ivars = new InternalMap();
            case value:
              throw('ERROR! Expected Obj type, got: ${Inspect.call(value)}');
          }
          valueStack.push(Obj(instance));
        case SetAttribute(name):
          var self:RObject = null;
          switch(valueStack.pop()) {
            case Obj(object): self = object;
            case value:
              throw('ERROR! Can only return objects. But tried to return: ${Inspect.call(value)}');
          }
          var value:Dynamic;
          switch(valueStack.pop()) {
            case Data(data):  value = data;
            case Obj(object): value = object;
          }
          Reflect.setProperty(self, name, value);
          valueStack.push(Obj(self));
        case EvalAst(ast):
          stackFrames.push(new StackFrame({
            binding:    stackFrames.peek.binding,
            ast:        ast,
            evaluation: Compile.call(ast),
            returned:   world.rNil,
          }));
        case PushReturned:
          valueStack.push(Obj(stackFrames.peek.returned));
        case Return:
          stackFrames.pop();
          switch(valueStack.pop()) {
            case Obj(object):
              this.currentExpression    = object;
              stackFrames.peek.returned = object;
              foundExpression           = true;
              state.index               = 0;
            case value:
              throw('ERROR! Can only return objects. But tried to return: ${Inspect.call(value)}');
          }
        // should this just go away, and we explicitly handle the case where the stack is empty?
        case Emit:
          switch(valueStack.peek) {
            case Obj(object):
              this.currentExpression = object;
              foundExpression        = true;
            case value:
              throw('ERROR! Can only emit objects. But tried to emit: ${Inspect.call(value)}');
          }
        case AdvanceState(nextState):
          state.index             = 0;
          evaluation.currentState = evaluation.states.get(nextState);
      }
    }

    if(stackFrames.length == 1)
      isInProgress = false;

    // trace("\033[34mRETURNING " + Inspect.call(currentExpression) +
    //     "\033[35mIN PROGRESS: " + isInProgress + "\033[33m");

    return currentExpression;
  }

  // ----- private -----
}
