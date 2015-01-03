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

// Flixel imports
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;
import flixel.util.FlxColor;

using flixel.util.FlxSpriteUtil;


// TODO: rename
class MenuState extends FlxState {
  private var _sprBack:FlxSprite;

  override public function create():Void {
    add(new FlxText(10, 10, 100, "Hello, World!"));

    // /Users/josh/ref/haxe/flixel/flixel/util/FlxColor.hx
    // public function makeGraphic(Width:Int, Height:Int, Color:Int = FlxColor.WHITE, Unique:Bool = false, ?Key:String):FlxSprite
    _sprBack = new FlxSprite().makeGraphic(120, 120, FlxColor.TRANSPARENT);

    // public static function drawRect(sprite:FlxSprite,
    //   X:Float, Y:Float, Width:Float, Height:Float, Color:Int,
    //   ?lineStyle:LineStyle, ?fillStyle:FillStyle, ?drawStyle:DrawStyle
    // ):FlxSprite
    _sprBack.drawRect(1, 1, 118, 44,  FlxColor.WHITE);
    _sprBack.drawRect(1, 46, 118, 73, FlxColor.BLUE);
    _sprBack.screenCenter(true, true);
    add(_sprBack);


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

    var worldDs     = ruby.Bootstrap.bootstrap();
    var world       = new ruby.World(worldDs);
    var interpreter = world.interpreter;
    var ast         = ruby.ParseRuby.fromCode(rawCode);

    interpreter.pushCode(ast);

    trace("CODE TO INTERPRET: \n" + rawCode);
    trace("--------------------");

    while(interpreter.isInProgress) {
      trace(world.inspect(interpreter.currentExpression));
      interpreter.nextExpression();
    }
    trace("--------------------");
    trace("PRINTED: " + world.printedToStdout);

    super.create();
  }

  override public function destroy():Void {
    _sprBack = flixel.util.FlxDestroyUtil.destroy(_sprBack);
    super.destroy();
	}

  override public function update():Void {
    super.update();
  }
}
