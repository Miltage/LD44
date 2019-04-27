package;

import openfl.geom.Point;

typedef NavPoint = { x:Float, y:Float, neighbours:Array<NavPoint>, parent:NavPoint };

class NavMesh
{

  private var nodes:Array<NavPoint>;
  
  public function new()
  {
    nodes = new Array<NavPoint>();

    addNode(100, 100);
    addNode(200, 350);
    addNode(245, 530);
    addNode(452, 428);
    addNode(445, 205);
    addNode(778, 230);
    addNode(829, 419);

  }

  public function getNodes():Array<NavPoint>
  {
    return nodes;
  }

  private function addNode(x:Float, y:Float):Void
  {
    var np = { x:x, y:y, neighbours:[], parent:null };

    for (node in nodes)
    {
      if (los(new Point(np.x, np.y), new Point(node.x, node.y), 10))
      {
        node.neighbours.push(np);
        np.neighbours.push(node);
      }
    }

    nodes.push(np);
  }

  public function findPath(p0:Point, p1:Point):Array<Point>
  {
    var result = new Array<Point>();

    if(los(p0, p1, 4))
    {
      result.push(p1);
      return result;
    }

    var startNode = getClosestNode(p0);
    if(startNode == null)
    {
      trace("cant find start node");
      return result;
    }
    var endNode = getClosestNode(p1);
    if(endNode == null)
    {
      trace("cant find end node");
      return result;
    }

    var checked = new Array<NavPoint>();
    var unchecked = new Array<NavPoint>();

    var current = startNode;
    while (current.x != endNode.x || current.y != endNode.y)
    {
      checked.push(current);
      var neighbours = getNeighboursByDistance(current, p1);
      for (n in neighbours)
      {
        if (!arrayContainsNode(checked, n) && !arrayContainsNode(unchecked, n))
        {
          n.parent = current;
          unchecked.push(n);
        }
      }
      if (unchecked.length == 0)
      {
        trace("could not solve");
        return result;
      }
      current = unchecked.shift();
    }

    result.push(p1);
    while (current.x != startNode.x || current.y != startNode.y)
    {
      result.push(new Point(current.x, current.y));
      current = current.parent;
    }
    result.push(new Point(startNode.x, startNode.y));

    for (node in nodes)
      node.parent = null;

    return result;
  }

  private function getNodesByDistance(p:Point):Array<NavPoint>
  {
    var result = nodes.copy();

    for (i in 0...result.length-1)
    {
      for (j in i+1...result.length)
      {
        var di = Point.distance(p, new Point(result[i].x, result[i].y));
        var dj = Point.distance(p, new Point(result[j].x, result[j].y));
        if (dj < di)
        {
          var t = result[i];
          result[i] = result[j];
          result[j] = t;
        }
      }
    }

    return result;
  }

  private function getClosestNode(p:Point):NavPoint
  {
    var result = getNodesByDistance(p);
    for (node in result)
    {
      if (los(p, new Point(node.x, node.y), 1))
        return node;
    }
    return null;
  }

  private function arrayContainsNode(a:Array<NavPoint>, n:NavPoint):Bool
  {
    for(i in a){
      if(i.x == n.x && i.y == n.y)
        return true;
    }
    return false;
  }

  private function getNeighboursByDistance(n:NavPoint, p:Point):Array<NavPoint>
  {
    var result = n.neighbours.copy();

    for (i in 0...result.length-1)
    {
      for (j in i+1...result.length)
      {
        var di = Point.distance(p, new Point(result[i].x, result[i].y));
        var dj = Point.distance(p, new Point(result[j].x, result[j].y));
        if (dj < di)
        {
          var t = result[i];
          result[i] = result[j];
          result[j] = t;
        }
      }
    }

    return result;
  }

  public function los(p0:Point, p1:Point, size:Int = 1):Bool
  {
    if(Point.distance(p0, p1) < size) return true;

    var x0 = Std.int(p0.x);
    var x1 = Std.int(p1.x);
    var y0 = Std.int(p0.y);
    var y1 = Std.int(p1.y);
    var dx:Int = Std.int(x1-x0);
    var dy:Int = Std.int(y1-y0);
    var stepx:Int;
    var stepy:Int;
  
    if (dx<0) { dx*=-1; stepx=-1; } else { stepx=1; }
    if (dy<0) { dy*=-1; stepy=-1; } else { stepy=1; }
    
    dy <<= 1; // *= 2;
    dx <<= 1;
    
    if (dx > dy)
    {
      var fraction:Float = dy - (dx >> 1);
      while (x0 != x1)
      {
        if (fraction >= 0)
        {
          y0 += stepy;
          fraction -= dx;
        }
        x0 += stepx;
        fraction += dy;
        var bbs = Main.getGameInstance().getBBs(new BB(null, x0 - 10, y0 - 10, x0 + 10, y0 + 10));
        for (bb in bbs)
        {
          if (bb.intersects(x0 - size, y0 - size, x0 + size, y0 + size))
            return false;
        }
      }
    } 
    else
    {
      var fraction:Float = dx - (dy >> 1);
      while (y0 != y1)
      {
        if (fraction >= 0)
        {
          x0 += stepx;
          fraction -= dy;
        }
        y0 += stepy;
        fraction += dx;
        var bbs = Main.getGameInstance().getBBs(new BB(null, x0 - 10, y0 - 10, x0 + 10, y0 + 10));
        for (bb in bbs)
        {
          if (bb.intersects(x0 - size, y0 - size, x0 + size, y0 + size))
            return false;
        }
      }
    }

    return true;
  }
}