package;

// Interpreter dependencies (TODO: just pulling in everything for now, come back and go through this)
import Stack;
import ruby.ds.Errors;
import ruby.ds.InternalMap;
import ruby.ds.Interpreter;
import ruby.ds.Objects;
import ruby.ds.World;
import ruby.Bootstrap;
import ruby.Core;
import ruby.Http;
import ruby.Interpreter;
import ruby.LanguageGoBag;
import ruby.ParseRuby;
import ruby.World;

// Flash imports
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.Lib;

// Flixel imports
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.ui.FlxButton;
import flixel.text.FlxText;
import flixel.util.FlxMath;
import flixel.util.FlxColor;
import flixel.group.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;

using flixel.util.FlxSpriteUtil;
using ruby.LanguageGoBag;


class Main extends Sprite {
  var game:FlxGame;

  public static function main():Void {
    Lib.current.addChild(new Main()); // fkn global state everywhere :(
  }

  public function new() {
    super();
    if(stage == null) addEventListener(Event.ADDED_TO_STAGE, init);
    else              init();
  }

  private function init(?e:Event):Void {
    // cleanup
    if (hasEventListener(Event.ADDED_TO_STAGE))
      removeEventListener(Event.ADDED_TO_STAGE, init);

    // create game
    var initialStateClass : Class<FlxState> = RubyInterpreter;
    var gameWidth         : Int             = 1280; // might change, depending on your zoom.
    var gameHeight        : Int             = 960;  // might change, depending on your zoom.
    var updateFps         : Int             = 60;   // how often to call update
    var drawFps           : Int             = 60;   // how often to call draw
    var skipSplash        : Bool            = true; // this splash thing is the reason FlxGame takes a class instead of an instance, and thus I can't give arguments to my first MenuState (though, they could just take a function that returns the thing :/)
    var startFullscreen   : Bool            = false;
    var stageWidth        : Int             = Lib.current.stage.stageWidth;
    var stageHeight       : Int             = Lib.current.stage.stageHeight;
    var zoom              : Float           = Math.min(stageWidth/gameWidth, stageHeight/gameHeight);
    gameWidth  = Math.ceil(stageWidth  / zoom);
    gameHeight = Math.ceil(stageHeight / zoom);
    game       = new flixel.FlxGame(gameWidth, gameHeight, initialStateClass, zoom, updateFps, drawFps, skipSplash, startFullscreen);
    addChild(game);

    // No fancy cursors -- for whatever reason, this has to come after the game is created, or it segfaults
    FlxG.mouse.useSystemCursor = true;
  }
}

class RubyInterpreter extends FlxState {
  private var callStack   : Callstack;
  private var interpreter : ruby.Interpreter;
  private var world       : ruby.World;

  // FlxGame takes a class instead of an instance.
  // This means I can't init it with args (was going to send a PR, but I couldn't get the test suite to run --
  // they had a nice shell script for it, I'm probably just too ignorant to know how to do it right)
  // Anyway, there's no real reason that FlxGame can't take args (its instantiated in FlxGame and FlxSplash,
  // and I have no desire to see the splash screen every time I run the code),
  // but I'm uncomfortable with subclassing FlxGame b/c these internal methods could easily change.
  // So, dropping initialization here instead of in Main where it probably goes
  override public function create():Void {
    super.create();

    // set up the interpreter (this setup should all be pushed up the callstack, I think)
    var rawCode = 'class User\n' +
                  '  def initialize(name)\n' +
                  '    self.name = name\n' +
                  '  end\n' +
                  '\n'+
                  '  def name\n' +
                  '    @name\n' +
                  '  end\n' +
                  '\n'+
                  '  def name=(name)\n' +
                  '    @name = name\n' +
                  '  end\n' +
                  'end\n' +
                  '\n' +
                  'user = User.new("Josh")\n' +
                  'puts user.name';
    var worldDs = ruby.Bootstrap.bootstrap();
    var ast     = ruby.ParseRuby.fromCode(rawCode);
    trace("CODE WE ARE INTERPRETING\n"+
          "------------------------\n"+
          rawCode);
    world       = new ruby.World(worldDs);
    interpreter = world.interpreter;
    interpreter.pushCode(ast);

    // set up the callstack
    callStack = new Callstack();
    add(callStack);
  }

  override public function update():Void {
    if(interpreter.isInProgress) { // everything is done a this point, how do I quit?
      if(FlxG.keys.justReleased.N) {
        world.inspect(interpreter.currentExpression);
        interpreter.step();
        callStack.frames = interpreter.state.stack;
        super.update();
      }
    }
    if(FlxG.keys.justReleased.Q) {
      #if desktop
      flash.system.System.exit(0); // based on the tutorial
      #end
    }
  }
}


class Callstack extends FlxTypedGroup<FlxSprite> {
  public var frames : List<StackFrame>;
  private inline static var paddingSize = 10;

  public function new() {
    super();
    this.frames  = new List();
    add(title());
  }

  override public function update() {
    clear();
    var title   = add(this.title());
    var yOffset = title.frameHeight + paddingSize;
    for(frame in frames.fromEnd()) {
      var text = add(new FlxText(paddingSize, yOffset, 0, frameText(frame), 20));
      yOffset += text.frameHeight + paddingSize;
    }
  }

  private function title() {
    return new FlxText(paddingSize  /*x*/,
                       paddingSize  /*y*/,
                       0            /*width: 0=autocalculate*/,
                       "Callstack",
                       25           /*font size*/);
  }

  private function frameText(frame:ruby.ds.Interpreter.StackFrame):String {
    var varNames = frame.binding.lvars.keys();
    var text = "";

    text += Type.enumConstructor(frame.state) + "(";
    switch (frame.state) {
      case Default           : text += "Default";
      case Nil               : text += "Nil";
      case Self              : text += "Self";
      case True              : text += "True";
      case False             : text += "False";
      case Integer   (value) : text += "Integer("+Std.string(value)+")";
      case Float     (value) : text += "Float("+Std.string(value)+")";
      case String    (value) : text += 'String("'+Std.string(value)+'")';
      case GetLvar   (state) : text += Type.enumConstructor(state);
      case SetLvar   (state) : text += Type.enumConstructor(state);
      case GetIvar   (state) : text += Type.enumConstructor(state);
      case SetIvar   (state) : text += Type.enumConstructor(state);
      case Const     (state) : text += Type.enumConstructor(state);
      case Exprs     (state) : text += Type.enumConstructor(state);
      case OpenClass (state) : text += Type.enumConstructor(state);
      case Send      (state) : text += Type.enumConstructor(state);
      case Value     (state) : text += Type.enumConstructor(state);
      case Def       (state) : text += Type.enumConstructor(state);
    }
    text += ")";

    if(varNames.hasNext()) text += " | locals:";
    for(name in varNames)  text += " " + name;
    return text;
  }
}
