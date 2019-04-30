package;

interface Collidable 
{
  public var x(get, set):Float;
  public var y(get, set):Float;
  public function collidesWith(entity:Entity):Bool;
  public function resolveCollision(entity:Entity):Void;
  public function getRadius():Int;
}