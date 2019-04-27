package;

class BB {
  public var x0:Float;
  public var y0:Float;
  public var x1:Float;
  public var y1:Float;
  public var owner:BBOwner;

  public function new(owner:BBOwner, x0:Float, y0:Float, x1:Float, y1:Float)
  {
    this.owner = owner;
    this.x0 = x0;
    this.y0 = y0;
    this.x1 = x1;
    this.y1 = y1;
  }

  public function intersects(xx0:Float, yy0:Float, xx1:Float, yy1:Float):Bool
  {
    if (xx0 >= x1 || yy0 >= y1 || xx1 <= x0 || yy1 <= y0) 
      return false;
    return true;
  }

  public function grow(s:Float):BB
  {
    return new BB(owner, x0 - s, y0 - s, x1 + s, y1 + s);
  }

  public function intersectsBB(bb:BB):Bool
  {
    if (bb.x0 >= x1 || bb.y0 >= y1 || bb.x1 <= x0 || bb.y1 <= y0)
      return false;
    return true;
  }
}