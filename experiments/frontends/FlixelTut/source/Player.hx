package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxAngle;

class Player extends FlxSprite {
  public var speed:Float = 200;

  public function new(x:Float=0, y:Float=0) {
    super(x, y);
    makeGraphic(16, 16, FlxColor.BLUE);
    drag.x = drag.y = 1600; // friction
  }


  override public function update():Void {
    movement();
    super.update();
  }

  private function movement():Void {
    var _up    = FlxG.keys.anyPressed(["UP",    "W"]);
    var _down  = FlxG.keys.anyPressed(["DOWN",  "S"]);
    var _left  = FlxG.keys.anyPressed(["LEFT",  "A"]);
    var _right = FlxG.keys.anyPressed(["RIGHT", "D"]);

    if(_up && _down)
      _up = _down = false;

    if(_left && _right)
      _left = _right = false;

    if( _up || _down || _left || _right) {
      var mA:Float =
        if      (_down && _right)  45;
        else if (_down && _left)  135;
        else if (_up   && _left)  225;
        else if (_up   && _right) 315;
        else if (_up)             270;
        else if (_down)            90;
        else if (_left)           180;
        else                        0;
      // NOTE: on 4.0, this becomes FlxPoint#rotate,
      // and the direction of the angle isn't inverted
      // (I'm on 3.3.6)
      FlxAngle.rotatePoint(speed, 0, 0, 0, mA, velocity);
    }
  }
}
