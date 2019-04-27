package;

import openfl.display.Sprite;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.geom.Point;
import openfl.Lib;
import openfl.Assets;

import Entity;
import Player;

class Game extends Sprite
{
  public static inline var SHADOW_ALPHA:Float = 0.2;

  private var input:InputController;
  private var player:Player;
  private var leftHand:Hand;
  private var rightHand:Hand;
  private var entities:Array<Entity>;
  private var worldBBs:Array<BB>;
  private var navMesh:NavMesh;

  private var container:Sprite;
  private var debug:Sprite;

  private var lastTime:Int;

  public function new(input:InputController)
  {
    super();

    this.input = input;

    lastTime = Lib.getTimer();
  }

  public function reset():Void
  {
    removeChild(container);
    init();
  }

  public function init():Void
  {
    worldBBs = new Array<BB>();
    worldBBs.push(new BB(null, 160, 170, 175, 950));
    worldBBs.push(new BB(null, 160, 170, 1522, 185));
    worldBBs.push(new BB(null, 580, 170, 595, 250));
    worldBBs.push(new BB(null, 580, 324, 595, 425));
    worldBBs.push(new BB(null, 580, 390, 1100, 410));
    worldBBs.push(new BB(null, 160, 920, 785, 950));
    worldBBs.push(new BB(null, 160, 540, 785, 560));
    worldBBs.push(new BB(null, 581, 507, 595, 560));
    worldBBs.push(new BB(null, 770, 540, 785, 695));
    worldBBs.push(new BB(null, 770, 815, 785, 950));
    worldBBs.push(new BB(null, 1085, 170, 1100, 425));
    worldBBs.push(new BB(null, 1085, 510, 1100, 560));
    worldBBs.push(new BB(null, 900, 540, 1180, 560));
    worldBBs.push(new BB(null, 1420, 540, 1520, 560));
    worldBBs.push(new BB(null, 903, 540, 920, 695));
    worldBBs.push(new BB(null, 903, 815, 920, 950));
    worldBBs.push(new BB(null, 903, 918, 1522, 950));
    worldBBs.push(new BB(null, 1506, 170, 1522, 950));

    entities = new Array<Entity>();
    navMesh = new NavMesh();

    container = new Sprite();
    addChild(container);

    var sw = Lib.current.stage.stageWidth;
    var sh = Lib.current.stage.stageHeight;

    {
      var bitmapData:BitmapData = Assets.getBitmapData("assets/plot.png");
      var plot = new Bitmap(bitmapData);
      plot.scaleX = plot.scaleY = Main.SCALE;
      container.addChild(plot);
    }

    #if debug
    {
      debug = new Sprite();
      drawDebug();
      container.addChild(debug);
    }
    #end

    {
      player = new Player();
      player.x = 400;
      player.y = 400;
      container.addChild(player);
      entities.push(player);
    }

    {
      leftHand = new Hand(true);
      leftHand.x = player.x;
      leftHand.y = player.y;
      container.addChild(leftHand);
      entities.push(leftHand);
    }

    {
      rightHand = new Hand();
      rightHand.x = player.x;
      rightHand.y = player.y;
      container.addChild(rightHand);
      entities.push(rightHand);
    }
  }

  public function onClick(mx:Float, my:Float):Void
  {
    var xx = mx - container.x;
    var yy = my - container.y;
    trace(xx, yy);

    player.setPath(navMesh.findPath(new Point(player.x, player.y), new Point(xx, yy)));
  }

  public function update():Void
  {
    var time = Lib.getTimer();
    var delta = time - lastTime;
    lastTime = time;

    // collision
    for (i in 0...entities.length)
      for (j in (i + 1)...entities.length)
        if (entities[i].collidesWith(entities[j]) && entities[i].isCollidingWith(entities[j]))
          entities[i].resolveCollision(entities[j]);

    // depth sorting
    for (i in 0...container.numChildren)
    {
      for (j in i...container.numChildren)
      {
        if (container.getChildAt(i).y > container.getChildAt(j).y)
          container.swapChildrenAt(i, j);
      }
    }

    for (entity in entities)
      entity.update(delta);

    // keep hands at player's sides
    var left = player.getOffset(-60, 30);
    leftHand.setTarget(left.x, left.y);
    var right = player.getOffset(60, 30);
    rightHand.setTarget(right.x, right.y);

    // move world
    if (input.isKeyDown('W'.code))
      container.y += 10;
    else if (input.isKeyDown('S'.code))
      container.y -= 10;
    if (input.isKeyDown('A'.code))
      container.x += 10;
    else if (input.isKeyDown('D'.code))
      container.x -= 10;
  }

  public function getBBs(bounds:BB):Array<BB>
  {
    var list:Array<BB> = new Array<BB>();
    bounds = bounds.grow(5);    

    for (bb in worldBBs)
    {
      if (bounds.intersectsBB(bb))
        list.push(bb);
    }

    /*for(e in extras){
      if(bounds.intersectsBB(e.getBB()))
        list.push(e.getBB());
    }*/

    return list;
  }

  private function drawDebug():Void
  {
    var sw = Lib.current.stage.stageWidth;
    var sh = Lib.current.stage.stageHeight;
    
    // draw bbs
    debug.graphics.lineStyle(1, 0x00ff00, 1);
    for (bb in getBBs(new BB(null, 0, 0, sw * Main.SCALE, sh * Main.SCALE)))
    {
      debug.graphics.drawRect(bb.x0, bb.y0, bb.x1 - bb.x0, bb.y1 - bb.y0);
    }

    // draw nav mesh
    debug.graphics.lineStyle(1, 0xff0000, 1);
    for (node in navMesh.getNodes())
    {
      debug.graphics.drawEllipse(node.x - 3, node.y - 1.5, 6, 3);
      for (n in node.neighbours)
      {
        debug.graphics.moveTo(node.x, node.y);
        debug.graphics.lineTo(n.x, n.y);
      }
    }
  }
}