package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;

using flixel.util.FlxSpriteUtil;

// A FlxState which can be used for the game's menu.
class MenuState extends FlxState {

  private var _btnPlay:FlxButton;

  // called to initialize a new "to state"
  override public function create():Void {
    _btnPlay = new FlxButton(0, 0, "Play", clickPlay);
    _btnPlay.screenCenter();
    add(_btnPlay);
    super.create();
  }

  private function clickPlay():Void {
    FlxG.switchState(new PlayState()); // oh my :(
  }

  // called when this state is destroyed
  override public function destroy():Void {
    super.destroy();
  }

  // called once every frame.
  override public function update():Void {
    super.update();
  }
}
