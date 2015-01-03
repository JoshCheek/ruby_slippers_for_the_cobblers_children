package;

import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.Lib;
import flixel.FlxGame;
import flixel.FlxState;

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

    var initialState    : Class<FlxState> = MenuState; // IDK why I pass a class instead of an instance or a function, it ultimately calls Type.createInstance, idk why they do that instead of new (maybe new won't look up a local var?)
    var gameWidth       : Int             = 640;       // might change, depending on your zoom.
    var gameHeight      : Int             = 480;       // might change, depending on your zoom.
    var updateFps       : Int             = 60;        // how often to call update
    var drawFps         : Int             = 60;        // how often to call draw
    var skipSplash      : Bool            = true;
    var startFullscreen : Bool            = false;
    var stageWidth      : Int             = Lib.current.stage.stageWidth;
    var stageHeight     : Int             = Lib.current.stage.stageHeight;
    var zoom            : Float           = Math.min(stageWidth/gameWidth, stageHeight/gameHeight);

    gameWidth  = Math.ceil(stageWidth  / zoom);
    gameHeight = Math.ceil(stageHeight / zoom);

    addChild(new FlxGame(gameWidth, gameHeight, initialState, zoom, updateFps, drawFps, skipSplash, startFullscreen));
  }
}
