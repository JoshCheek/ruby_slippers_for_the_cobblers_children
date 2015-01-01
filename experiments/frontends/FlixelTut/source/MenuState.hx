package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;

// A FlxState which can be used for the game's menu.
class MenuState extends FlxState {
  // called to initialize a new "to state"
  override public function create():Void {
    super.create();
  }

  // called when this state is destroyed
  override public function destroy():Void {
    super.destroy();
  }

  // called once every frame.
  override public function update():Void {
    add(new FlxText(10, 10, 100, "Hello, World!"));
    super.update();
  }
}
