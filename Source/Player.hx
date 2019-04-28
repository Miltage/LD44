package;

import openfl.display.Sprite;
import openfl.display.BitmapData;
import openfl.geom.Point;
import openfl.Assets;
import openfl.Lib;

import spritesheet.AnimatedSprite;
import spritesheet.Spritesheet;
import spritesheet.data.BehaviorData;
import spritesheet.importers.BitmapImporter;

import Entity;

class Player extends Entity implements Combatant
{
  public static inline var FRAME_RATE:Int = 12;
  public static inline var RADIUS:Int = 30;
  public static inline var SPEED:Float = 250;
  public static inline var SPRITE_WIDTH:Int = 50;
  public static inline var SPRITE_HEIGHT:Int = 50;

  private var animation:AnimatedSprite;
  private var weapon:WeaponType;

  public function new()
  {
    super();

    {
      var bitmapData:BitmapData = Assets.getBitmapData("assets/coin.png");
      var spritesheet:Spritesheet = BitmapImporter.create(bitmapData, 16, 1, SPRITE_WIDTH, SPRITE_HEIGHT);

      spritesheet.addBehavior(new BehaviorData("0", [0], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("1", [1], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("2", [2], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("3", [3], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("4", [4], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("5", [5], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("6", [6], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("7", [7], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("8", [8], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("9", [9], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("10", [10], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("11", [11], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("12", [12], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("13", [13], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("14", [14], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("15", [15], true, FRAME_RATE));

      animation = new AnimatedSprite(spritesheet, true);
      animation.x = -SPRITE_WIDTH * Main.SCALE/2;
      animation.y = -SPRITE_HEIGHT * Main.SCALE*0.85;
      animation.scaleX = animation.scaleY = Main.SCALE;
      addChild(animation);
    }

    weapon = REVOLVER;

    animation.showBehavior("8");
  }

  public function getWeapon():WeaponType
  {
    return weapon;
  }

  public function setWeapon(w:WeaponType):Void
  {
    weapon = w;
  }

  public function move(dir:MoveDirection):Void
  {
    targetVelocity = getDirection(dir);
    targetVelocity.normalize(SPEED);
  }

  public function stop():Void
  {
    targetVelocity.setTo(0, 0);
  }

  override public function update(delta:Int):Void
  {
    super.update(delta);

    if (x - RADIUS < 0) x = RADIUS;
    else if (x + RADIUS > Lib.current.stage.stageWidth) x = Lib.current.stage.stageWidth - RADIUS;
    if (y - RADIUS/2 < 300) y = 300 + RADIUS/2;
    else if (y + RADIUS/2 > Lib.current.stage.stageHeight) y = Lib.current.stage.stageHeight - RADIUS/2;

    var rads = Math.atan2(facing.y, facing.x);
    var degs = rads / Math.PI * 180 + 90;
    if (degs < 0)
      degs += 360;
    var frame = Math.abs(Math.floor(degs / (360/16)));

    animation.showBehavior("" + frame);

    animation.update(delta);
  }

  override public function collidesWith(entity:Entity):Bool
  {
    return Std.is(entity, Mobster) || Std.is(entity, Hand) || Std.is(entity, TwoHands);
  }
}