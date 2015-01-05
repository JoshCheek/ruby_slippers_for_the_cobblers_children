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

    // Use normal mouse (segfaults if you put this before the game. IDK why)
    FlxG.mouse.useSystemCursor = true;
  }
}

class RubyInterpreter extends FlxState {
  // private var _callStack   : Callstack;
  private var _interpreter : ruby.Interpreter;
  private var _world       : ruby.World;

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
    trace("AST: " + ast);
    _world       = new ruby.World(worldDs);
    _interpreter = _world.interpreter;
    _interpreter.pushCode(ast);

    // set up the callstack
    // _callStack = new Callstack(960);
    // add(_callStack);

    trace("CODE TO INTERPRET: \n" + rawCode);
    trace("--------------------");
  }

  // this is not getting called :/
  override public function destroy():Void {
    trace("--------------------");
    // callStack = flixel.util.FlxDestroyUtil.destroy(callStack);
    super.destroy();
	}

  // TODO: exit when isInProgress becomes false
  // TODO: trigger this by clicking or something
  override public function update():Void {
    if(_interpreter.isInProgress // everything is done a this point, how do I quit?
     ) {
      trace("ABOUT TO STEP");
      var result = _interpreter.step();
      trace("BACK!");
      // trace(result);
      // switch(result) {
      //   case Push(replacementState, pushed, binding): _callStack.push(replacementState, pushed, binding);
      //   case Pop(obj):                                _callStack.pop(obj);
      //   case NoAction(replacementState):              _callStack.replaceState(replacementState);
      // }
      // _callStack.update();
      // _world.inspect(_interpreter.currentExpression);
    }

    super.update(); // updates children (e.g. callstack)
  }
}

class StackFrame extends FlxSpriteGroup {
  public function new(pushed, binding, width, stackHeight) {
    super(10, stackHeight);
    this.frameWidth = width;
    // makeGraphic(10, stackHeight,
  }

  public function replaceState(replacementState) {
  }
}

// // TODO: currently centering in the outer container
// class Callstack extends FlxTypedGroup<FlxSprite> {
//   private var background  : FlxSprite;
//   private var heading     : FlxText;
//   private var frames      : Stack<StackFrame>;
//   private var _width      : Int;
//   private var _height     : Int;
//   private var stackHeight : Int;
//
//   public function new(height:Int) {
//     super();
//     this._width       = 200; // px
//     this._height      = 960;
//     this.frames       = new Stack();
//     this.background =   add(new FlxSprite().makeGraphic(_width/*w*/, _height/*h*/, FlxColor.GREEN));
//     var text = new FlxText(10/*x*/, 10/*y*/, 0/*width: 0=autocalculate*/, "Callstack", 25/*font size*/);
//     add(text);
//     this.stackHeight = text.frameHeight + 10;
//   }
//
//   public function push(replacementState, pushed, binding) {
//     replaceState(replacementState);
//     var frame = new StackFrame(pushed, binding, _width, stackHeight+10);
//     frame.update();
//     this.stackHeight += 10 + frame.frameHeight;
//     frames.push(frame);
//     add(frame);
//   }
//
//   public function pop(obj) {
//     var frame = frames.pop();
//     this.stackHeight -= 10;
//     this.stackHeight -= frame.frameHeight;
//     remove(frame);
//     frame.destroy();
//   }
//
//   public function replaceState(replacementState) {
//     var crntFrame = frames.peek;
//     this.stackHeight -= crntFrame.frameHeight;
//     crntFrame.replaceState(replacementState);
//     crntFrame.update();
//     this.stackHeight += crntFrame.frameHeight;
//   }
// }
