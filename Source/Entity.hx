package;

import openfl.display.Sprite;
import openfl.geom.Point;
import openfl.Lib;

enum MoveDirection
{
  UP;
  DOWN;
  LEFT;
  RIGHT;
  UP_LEFT;
  UP_RIGHT;
  DOWN_LEFT;
  DOWN_RIGHT;
}

class Entity extends Sprite implements Collidable
{
  public static inline var FRICTION:Float = 0.6;

  private var velocity:Point;
  private var speed:Float;

  public function new()
  {
    super();

    velocity = new Point();
    speed = 5;
  }

  public function update(delta:Int):Void
  {
    x += velocity.x * speed;
    y += velocity.y * speed;

    var radius = Reflect.field(Type.getClass(this), "RADIUS");

    if (x - radius < 0) x = radius;
    else if (x + radius > Lib.current.stage.stageWidth) x = Lib.current.stage.stageWidth - radius;
    if (y - radius < 0) y = radius;
    else if (y + radius > Lib.current.stage.stageHeight) y = Lib.current.stage.stageHeight - radius;

    velocity.x *= FRICTION;
    velocity.y *= FRICTION;
  }

  public function moveToward(entity:Entity):Void
  {
    var dx = entity.x - x;
    var dy = entity.y - y;
    velocity = new Point(dx, dy);
    velocity.normalize(1);
  }

  public function withinDistance(x:Int, y:Int, radius:Int):Bool
  {
    var a = new Point(this.x, this.y);
    var b = new Point(x, y);
    var dist = Point.distance(a, b);
    return dist <= radius;
  }

  public function withinDistanceOf(entity:Entity, radius:Int):Bool
  {
    var a = new Point(this.x, this.y);
    var b = new Point(entity.x, entity.y);
    var dist = Point.distance(a, b);
    return dist <= radius;
  }

  public function isCollidingWith(collidable:Collidable):Bool
  {
    var a = new Point(this.x, this.y);
    var b = new Point(collidable.x, collidable.y);
    var dist = Point.distance(a, b);
    var radius1 = Reflect.field(Type.getClass(collidable), "RADIUS");
    var radius2 = Reflect.field(Type.getClass(this), "RADIUS");
    return dist < (radius1 + radius2);
  }

  public function collidesWith(entity:Entity):Bool
  {
    return false;
  }

  public function resolveCollision(entity:Entity):Void
  {
    var a = new Point(this.x, this.y);
    var b = new Point(entity.x, entity.y);
    var dist = Point.distance(a, b);
    var radius1 = Reflect.field(Type.getClass(entity), "RADIUS");
    var radius2 = Reflect.field(Type.getClass(this), "RADIUS");
    var overlap = dist - (radius1 + radius2);
    var dx = b.x - a.x;
    var dy = b.y - a.y;
    x += dx/dist*overlap/2;
    y += dy/dist*overlap/2;
  }

  private function getDirection(dir:MoveDirection):Point
  {
    return switch (dir)
    {
      case UP: new Point(0, -1);
      case DOWN: new Point(0, 1);
      case LEFT: new Point(-1, 0);
      case RIGHT: new Point(1, 0);
      case UP_LEFT: new Point(-0.7, -0.7);
      case UP_RIGHT: new Point(0.7, -0.7);
      case DOWN_LEFT: new Point(-0.7, 0.7);
      case DOWN_RIGHT: new Point(0.7, 0.7);
    }
  }
}