package;

import openfl.display.Sprite;
import openfl.geom.Point;

class Bullet extends Sprite
{
  public static inline var SPEED:Float = 70;

  private var velocity:Point;
  private var drawn:Bool;
  private var flagged:Bool;
  private var origin:TwoHands;

  public function new(origin:TwoHands, x:Float, y:Float, dx:Float, dy:Float)
  {
    super();

    velocity = new Point(dx * SPEED, dy * SPEED);

    this.x = x;
    this.y = y;
    this.origin = origin;

    graphics.lineStyle(4, 0xFFFFFF, 1);
    graphics.moveTo(0, -TwoHands.GUN_HEIGHT);
    graphics.lineTo(velocity.x, -TwoHands.GUN_HEIGHT + velocity.y);

    drawn = false;
    flagged = false;
  }

  public function update(delta:Int)
  {
    if (!drawn)
    {
      drawn = true;
      return;
    }

    x += velocity.x;
    y += velocity.y;
  }

  public function doHitDetection(entities:Array<Entity>):Void
  {
    for (entity in entities)
    {
      if (Std.is(entity, Hand) || Std.is(entity, TwoHands)) continue;
      if (entity == origin || entity == cast origin.getOwner()) continue;

      if (Std.is(entity, Mobster) && cast(entity, Mobster).isDead()) continue;

      var dx = entity.x - x;
      var dy = entity.y - y;
      var dist = Math.sqrt(dy*dx + dy*dy);
      var radius = Reflect.field(Type.getClass(entity), "RADIUS");

      if (dist < radius && !flagged)
      {
        entity.takeDamage(1, velocity.x, velocity.y);
        flagged = true;
        return;
      }
    }
  }

  public function getLength():Float
  {
    return velocity.length;
  }

  public function flaggedForRemoval():Bool
  {
    return flagged;
  }
}