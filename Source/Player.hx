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

enum PlayerTeam
{
  RED;
  BLUE;
}

class Player extends Entity
{
  public static inline var FRAME_RATE:Int = 12;
  public static inline var RADIUS:Int = 30;
  public static inline var SPRITE_WIDTH:Int = 100;
  public static inline var SPRITE_HEIGHT:Int = 100;

  private var animation:AnimatedSprite;
  private var lastMove:MoveDirection;

  public function new()
  {
    super();

    #if debug
    graphics.beginFill(0xDEFEC8, 1);
    graphics.drawCircle(0, 0, RADIUS);
    #end

    var bitmapData:BitmapData = Assets.getBitmapData("assets/trump_run.png");
    var spritesheet:Spritesheet = BitmapImporter.create(bitmapData, 6, 4, SPRITE_WIDTH, SPRITE_HEIGHT);

    spritesheet.addBehavior(new BehaviorData("walk_south", [0, 1, 2, 3, 4, 5], true, FRAME_RATE));
    spritesheet.addBehavior(new BehaviorData("walk_east", [6, 7, 8, 9, 10, 11], true, FRAME_RATE));
    spritesheet.addBehavior(new BehaviorData("walk_north", [12, 13, 14, 15, 16, 17], true, FRAME_RATE));
    spritesheet.addBehavior(new BehaviorData("walk_west", [18, 19, 20, 21, 22, 23], true, FRAME_RATE));

    spritesheet.addBehavior(new BehaviorData("idle_south", [1], false, 1));
    spritesheet.addBehavior(new BehaviorData("idle_east", [7], false, 1));
    spritesheet.addBehavior(new BehaviorData("idle_north", [13], false, 1));
    spritesheet.addBehavior(new BehaviorData("idle_west", [19], false, 1));

    animation = new AnimatedSprite(spritesheet, true);
    animation.x = -SPRITE_WIDTH/2;
    animation.y = -SPRITE_HEIGHT*0.75;
    addChild(animation);

    lastMove = DOWN;
  }

  public function move(dir:MoveDirection):Void
  {
    velocity = getDirection(dir);

    lastMove = dir;
  }

  override public function update(delta:Int):Void
  {
    super.update(delta);

    if (Math.abs(velocity.x) > Math.abs(velocity.y))
      animation.showBehavior(velocity.x > 0 ? "walk_east" : "walk_west", false);
    else
      animation.showBehavior(velocity.y > 0 ? "walk_south" : "walk_north", false);

    if (Math.abs(velocity.x) < 0.1 && Math.abs(velocity.y) < 0.1)
      animation.showBehavior(switch (lastMove) {
        case UP | UP_LEFT | UP_RIGHT: "idle_north";
        case DOWN | DOWN_LEFT | DOWN_RIGHT: "idle_south";
        case RIGHT: "idle_east";
        case LEFT: "idle_west";
      });

    animation.update(delta);
  }

  override public function collidesWith(entity:Entity):Bool
  {
    return Std.is(entity, Player);
  }
}