package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxAngle;

class Player extends FlxSprite {
  public var speed:Float = 200;

  public function new(x:Float=0, y:Float=0) {
    super(x, y);

    // loadGraphic("assets/images/player.png", true, 16, 16);
    // loadGraphic(AssetPaths.player__png, true, 16, 16);
    loadGraphic("assets/images/player.png", true, 16, 16);

    setFacingFlip(FlxObject.LEFT, false, false);
    setFacingFlip(FlxObject.RIGHT, true, false);

    // animation.FlxAnimationController#add(
    //   Name:String, Frames:Array<Int>, FrameRate:Int = 30, Looped:Bool = true
    // ):Void
    animation.add("d",  [0, 1, 0, 2], 6, false);
    animation.add("lr", [3, 4, 3, 5], 6, false);
    animation.add("u",  [6, 7, 6, 8], 6, false);

    width    = 8;
    height   = 14;
    offset.x = 4;
    offset.y = 2;
  }


  override public function update():Void {
    movement();
    super.update();
  }

  override public function draw():Void {
    if(velocity.x != 0 || velocity.y != 0) {
      switch(facing) {
        case FlxObject.LEFT, FlxObject.RIGHT: animation.play("lr");
        case FlxObject.UP:                    animation.play("u");
        case FlxObject.DOWN:                  animation.play("d");
      }
    }
    super.draw();
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

      // an int at least 2 bytes long (these are defined as 0x1000, depending which "bit" they set decides the direction)
      // not sure why they do this instead of using Enumerables, or 4 bits instead of 2 bytes
      facing = _up    ? FlxObject.UP    :
               _down  ? FlxObject.DOWN  :
               _left  ? FlxObject.LEFT  :
               _right ? FlxObject.RIGHT :
                        FlxObject.RIGHT;

      // NOTE: on 4.0, this becomes FlxPoint#rotate,
      // and the direction of the angle isn't inverted
      // (I'm on 3.3.6)
      FlxAngle.rotatePoint(speed, 0, 0, 0, mA, velocity);
    }
  }

}
