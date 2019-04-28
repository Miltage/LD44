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
  private var targetVelocity:Point;
  private var facing:Point;
  private var target:Point;
  private var path:Array<Point>;
  private var faceMoving:Bool;

  public function new()
  {
    super();

    #if debug
    var radius = Reflect.field(Type.getClass(this), "RADIUS");
    graphics.beginFill(0xff0000, 1);
    graphics.drawEllipse(-radius/2, -radius/4, radius, radius/2);
    #end

    velocity = new Point();
    targetVelocity = new Point();
    facing = new Point(0, 1);
    faceMoving = true;
  }

  public function update(delta:Int):Void
  {
    var radius = Reflect.field(Type.getClass(this), "RADIUS");
    var speed = Reflect.field(Type.getClass(this), "SPEED");

    if (x - radius < 0) x = radius;
    else if (x + radius > Lib.current.stage.stageWidth) x = Lib.current.stage.stageWidth - radius;
    if (y - radius < 290) y = 290 + radius;
    else if (y + radius > Lib.current.stage.stageHeight) y = Lib.current.stage.stageHeight - radius;

    if (target != null)
    {
      var dx = target.x - x;
      var dy = target.y - y;
      var dist = Math.sqrt(dx*dx + dy*dy);

      if (dist <= radius)
      {
        targetVelocity.setTo(0, 0);
        target = null;
      }
      else
      {
        targetVelocity.setTo(dx, dy);
        targetVelocity.normalize(speed);
      }
    }
    else
    {
      if (path != null && path.length > 0)
        target = path.pop();
      else
        path = null;
    }

    var dvx = targetVelocity.x - velocity.x;
    var dvy = targetVelocity.y - velocity.y;
    var len = Point.distance(velocity, targetVelocity);

    if (len > 0.01)
    {
      velocity.x += dvx * 0.2;
      velocity.y += dvy * 0.2;
    }
    else
      velocity.copyFrom(targetVelocity);

    x += velocity.x / delta;
    y += velocity.y / delta;

    if (velocity.length > 0.05 && faceMoving)
    {
      var dfx = facing.x - velocity.x;
      var dfy = facing.y - velocity.y;
      facing.x -= dfx * 0.2;
      facing.y -= dfy * 0.2;
      facing.normalize(1);
    }
  }

  public function setFaceMoving(fm:Bool):Void
  {
    faceMoving = fm;
  }

  public function setPath(path:Array<Point>):Void
  {
    target = null;
    this.path = path;
  }

  public function setTarget(tx:Float, ty:Float)
  {
    target = new Point(tx, ty);
  }

  public function push(dx:Float, dy:Float):Void
  {
    velocity.setTo(dx, dy);
  }

  public function facePoint(px:Float, py:Float):Void
  {
    var dx = px - x;
    var dy = py - y;
    facing = new Point(dx, dy);
    facing.normalize(1);
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

  public function getFacingDirection():Point
  {
    return facing;
  }

  public function getOffset(angle:Float, dist:Float):Point
  {
    var r = Math.atan2(facing.y, facing.x);
    var degs = r * 180 / Math.PI;
    var rads = (degs + angle) / 180 * Math.PI;
    var mx = Math.cos(rads);
    var my = Math.sin(rads);
    return new Point(x + mx * dist, y + my * dist);
  }
}