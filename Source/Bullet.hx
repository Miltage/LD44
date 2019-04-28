package;

import openfl.display.Sprite;
import openfl.geom.Point;

class Bullet extends Sprite
{
  public static inline var SPEED:Float = 70;

  private var velocity:Point;
  private var drawn:Bool;

  public function new(x:Float, y:Float, dx:Float, dy:Float)
  {
    super();

    velocity = new Point(dx * SPEED, dy * SPEED);

    this.x = x;
    this.y = y;

    graphics.lineStyle(2, 0xFFFFFF, 1);
    graphics.moveTo(0, -TwoHands.GUN_HEIGHT);
    graphics.lineTo(velocity.x, -TwoHands.GUN_HEIGHT + velocity.y);

    drawn = false;
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

  public function getLength():Float
  {
    return velocity.length;
  }
}