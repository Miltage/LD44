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

class Player extends Entity
{
  public static inline var FRAME_RATE:Int = 12;
  public static inline var RADIUS:Int = 30;
  public static inline var SPRITE_WIDTH:Int = 50;
  public static inline var SPRITE_HEIGHT:Int = 50;

  private var animation:AnimatedSprite;
  private var lastMove:MoveDirection;

  public function new()
  {
    super();

    #if debug
    graphics.beginFill(0xDEFEC8, 1);
    graphics.drawCircle(0, 0, RADIUS);
    #end

    var bitmapData:BitmapData = Assets.getBitmapData("assets/coin.png");
    var spritesheet:Spritesheet = BitmapImporter.create(bitmapData, 9, 1, SPRITE_WIDTH, SPRITE_HEIGHT);

    spritesheet.addBehavior(new BehaviorData("rotate", [0, 1, 2, 3, 4, 5, 6, 7, 8], true, FRAME_RATE));

    animation = new AnimatedSprite(spritesheet, true);
    animation.x = -SPRITE_WIDTH*Main.SCALE/2;
    animation.y = -SPRITE_HEIGHT*Main.SCALE*0.75;
    animation.scaleX = animation.scaleY = Main.SCALE;
    addChild(animation);

    lastMove = DOWN;

    animation.showBehavior("rotate");
  }

  public function move(dir:MoveDirection):Void
  {
    velocity = getDirection(dir);

    lastMove = dir;
  }

  override public function update(delta:Int):Void
  {
    super.update(delta);

    animation.update(delta);
  }

  override public function collidesWith(entity:Entity):Bool
  {
    return Std.is(entity, Player);
  }
}