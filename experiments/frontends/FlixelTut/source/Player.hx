package;

import flixel.FlxSprite;
import flixel.util.FlxColor;

class Player extends FlxSprite {
  var _player:Player;

  public function new(x:Float=0, y:Float=0) {
    super(x, y);
    makeGraphic(16, 16, FlxColor.BLUE);
  }
}
