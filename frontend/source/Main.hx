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



using flixel.util.FlxSpriteUtil;


class Main extends Sprite {
  public static function main():Void {
    Lib.current.addChild(new Main()); // fkn global state everywhere :(
  }

  public function new() {
    super();
    if(stage == null) addEventListener(Event.ADDED_TO_STAGE, init);
    else              init();
  }

  private function init(?e:Event):Void {
    if (hasEventListener(Event.ADDED_TO_STAGE))
      removeEventListener(Event.ADDED_TO_STAGE, init);

    var initialStateClass : Class<FlxState> = RubyInterpreter;
    var gameWidth         : Int             = 640;  // might change, depending on your zoom.
    var gameHeight        : Int             = 480;  // might change, depending on your zoom.
    var updateFps         : Int             = 60;   // how often to call update
    var drawFps           : Int             = 60;   // how often to call draw
    var skipSplash        : Bool            = true; // this splash thing is the reason FlxGame takes a class instead of an instance, and thus I can't give arguments to my first MenuState (though, they could just take a function that returns the thing :/)
    var startFullscreen   : Bool            = false;
    var stageWidth        : Int             = Lib.current.stage.stageWidth;
    var stageHeight       : Int             = Lib.current.stage.stageHeight;
    var zoom              : Float           = Math.min(stageWidth/gameWidth, stageHeight/gameHeight);

    gameWidth  = Math.ceil(stageWidth  / zoom);
    gameHeight = Math.ceil(stageHeight / zoom);

    addChild(new FlxGame(gameWidth, gameHeight, initialStateClass, zoom, updateFps, drawFps, skipSplash, startFullscreen));
  }
}

class RubyInterpreter extends FlxState {
  private var _callStack  : FlxSprite;
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
    world       = new ruby.World(worldDs);
    interpreter = world.interpreter;
    var ast     = ruby.ParseRuby.fromCode(rawCode);
    interpreter.pushCode(ast);

    // add(new FlxText(10, 10, 100, "Hello, World!"));

    // public function makeGraphic(Width:Int, Height:Int, Color:Int = FlxColor.WHITE, Unique:Bool = false, ?Key:String):FlxSprite
    _callStack = new FlxSprite().makeGraphic(120, 120, FlxColor.GREEN);

    // public static function drawRect(sprite:FlxSprite,
    //   X:Float, Y:Float, Width:Float, Height:Float, Color:Int,
    //   ?lineStyle:LineStyle, ?fillStyle:FillStyle, ?drawStyle:DrawStyle
    // ):FlxSprite
    _callStack.drawRect(1, 1, 118, 44,  FlxColor.WHITE);
    add(_callStack);


    trace("CODE TO INTERPRET: \n" + rawCode);
    trace("--------------------");

    super.create();
  }

  // this is not getting called :/
  override public function destroy():Void {
    trace("--------------------");
    trace("PRINTED: " + world.printedToStdout);
    _callStack = flixel.util.FlxDestroyUtil.destroy(_callStack);
    super.destroy();
	}

  override public function update():Void {
    while(interpreter.isInProgress) {
      trace(world.inspect(interpreter.currentExpression));
      interpreter.nextExpression();
    }
    super.update();
  }
}
