package ruby;

import ruby.ds.Ast;
import ruby.ds.InternalMap;
import ruby.ds.World;
import ruby.ds.objects.*;

using ruby.LanguageGoBag;
using ruby.WorldWorker;

class Interpreter {
  public var world:World;

  public static function fromBootstrap():Interpreter {
    return new Interpreter(WorldDomination.bootstrap());
  }

  // Does it make sense to move workToDo onto the interpreter,
  // or some other piece fo state that wraps the world?
  // not sure it's really part of the world (right now, at least, it's functions)
  public function new(world:World) {
    this.world = world;
  }

  // drains all, returning the list of expressions it saw
  public function drainAll():Array<RObject> {
    var drained = [];
    while(!isDrained()) drained.push(drainExpression());
    return drained;
  }

  // TODO: take into consideration the current evaluation
  public function isDrained():Bool
    return world.workToDo.length == 0;

  public var currentEvaluation:ruby.ds.EvaluationState = PullFromWorkQueue;
  public function drainExpression():RObject {
    // can we pattern match in if statements? that'd be nice
    switch(currentEvaluation) {
      case PullFromWorkQueue:
        var work = world.workToDo.pop();
        if(work == null) throw "Can't drain, b/c there's no work to do (is the AST case handled?)";
        currentEvaluation = work();
        drainExpression();
      case Finished(value):
        currentEvaluation       = PullFromWorkQueue;
        world.currentExpression = value;
    }
    return currentExpression();
  }

  public function fillFrom(ast:Ast):Void {
    inline function fill(work:Void->ruby.ds.EvaluationState)
      world.workToDo.push(work);

    switch(ast) {
      case AstExpressions(expressions):
        for(expr in expressions.reverseIterator()) {
          fillFrom(expr);
        };
      case AstString(value):
        fill(function() {
          var string:RString = {value: value, klass: world.objectClass, ivars: new InternalMap()};
          return Finished(string);
        });
      case AstSetLocalVariable(name, value):
        fill(function() {
          var obj = currentExpression();
          currentBinding().lvars.set(name, obj);
          return Finished(obj);
        });
        fillFrom(value);
      case AstGetLocalVariable(name):
        fill(function() {
          return Finished(currentBinding().lvars.get(name));
        });
      case AstClass(AstConstant(AstNil, name), superclassAst, body):
        fill(function() {
          world.stack.pop();
          return Finished(currentExpression());
        });
        fillFrom(body);
        fill(function() {
          var klass = getConstant(toplevelNamespace(), name);
          if(null == klass) {
            var _klass:RClass = {
              name:       name,
              klass:      world.klassClass,
              ivars:      new InternalMap(),
              imeths:     new InternalMap(),
              constants:  new InternalMap(),
              superclass: world.objectClass,
            };
            klass = _klass; // Fuck you
            setConstant(toplevelNamespace(), name, klass);
          }
          var binding = {
            klass:     world.objectClass,
            ivars:     new InternalMap(),
            self:      klass,
            defTarget: klass,
          }
          return Finished(currentExpression()); // FIXME
        });
      case AstNil:
        fill(function() return Finished(world.rubyNil));
      case AstTrue:
        fill(function() return Finished(world.rubyTrue));
      case AstFalse:
        fill(function() return Finished(world.rubyFalse));
      case AstSend(target, message, argAsts):
        fill(function() {
          var receiver:RObject;

          // find receiver
          switch(target) {
            case AstNil:
              receiver = currentBinding().self;
            case _:
              throw "Handle the case when the receiver is not null";
          }

          // evaluate args
          var args:Array<RObject> = []; // TODO: eval argAsts to get this

          // find method
          var methodBag = receiver.klass;
          while(methodBag != null && !hasMethod(methodBag, message))
            methodBag = methodBag.superclass;

          if(methodBag == null)
            throw "Could not find the method on " + Std.string(receiver); // eventually handle method_midding and nomethod errror

          var method = getMethod(methodBag, message);

          // put binding onto the stack
          var locals:InternalMap<RObject> = localsForArgs(method, args);

          var binding = {
            klass:     world.objectClass,
            ivars:     new InternalMap(),
            self:      receiver,
            defTarget: methodBag,
            lvars:     new InternalMap(),
          }

          world.stack.push(binding); // haven't tested defTarget here

          // last thing we will do is pop binding, get return value
          fill(function() {
            var returnValue = currentExpression();
            world.stack.pop();
            return Finished(returnValue);
          });

          // next thing we will do is evaluate the method
          fillFrom(method.body);

          // maybe switch over to returning an enum instead of an object
          return Finished(world.rubyNil);
        });
      case AstMethodDefinition(name, args, body):
        fill(function() {
          var method = {
            klass: world.objectClass,
            ivars: new InternalMap(),
            name:  name,
            args:  args,
            body:  body,
          }

          currentBinding().defTarget.imeths.set(name, method);
          return Finished(intern(name));
        });
      case node:
        throw "Unrecognized node: " + Std.string(node);
    }
  }
}
