package;

import openfl.display.Sprite;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.geom.Point;
import openfl.Lib;
import openfl.Assets;

import Entity;
import Player;

enum WeaponType
{
  NONE;
  REVOLVER;
  TOMMY;
}

class Game extends Sprite
{
  public static inline var SHADOW_ALPHA:Float = 0.2;

  private var input:InputController;
  private var player:Player;
  private var leftHand:Hand;
  private var rightHand:Hand;
  private var twoHands:TwoHands;
  private var entities:Array<Entity>;
  private var objects:Array<Interactable>;
  private var worldBBs:Array<BB>;
  private var navMesh:NavMesh;

  private var container:Sprite;
  private var debug:Sprite;
  private var tooltip:Tooltip;

  private var lastTime:Int;
  private var weapon:WeaponType;

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

    entities = new Array<Entity>();
    objects = new Array<Interactable>();
    navMesh = new NavMesh();

    container = new Sprite();
    addChild(container);

    tooltip = new Tooltip();
    addChild(tooltip);

    weapon = REVOLVER;

    var sw = Lib.current.stage.stageWidth;
    var sh = Lib.current.stage.stageHeight;

    {
      var bitmapData:BitmapData = Assets.getBitmapData("assets/scene.png");
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

    {
      twoHands = new TwoHands();
      twoHands.x = player.x;
      twoHands.y = player.y;
      container.addChild(twoHands);
      entities.push(twoHands);
    }
  }

  public function onClick(mx:Float, my:Float):Void
  {
    var xx = mx - container.x;
    var yy = my - container.y;
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

    tooltip.visible = false;

    for (entity in entities)
      entity.update(delta);

    for (object in objects)
      object.handleCursor(mouseX, mouseY, tooltip);

    // keep hands at player's sides
    var left = player.getOffset(-60, 30);
    leftHand.setTarget(left.x, left.y);
    var right = player.getOffset(60, 30);
    rightHand.setTarget(right.x, right.y);
    var front = player.getOffset(0, 45);
    twoHands.setTarget(front.x, front.y);

    // show correct weapon
    leftHand.visible = weapon == NONE;
    rightHand.visible = weapon == NONE;
    twoHands.visible = weapon != NONE;

    if (weapon != NONE)
    {
      player.setFaceMoving(false);
      player.facePoint(mouseX, mouseY);
      twoHands.facePoint(mouseX, mouseY);
    }
    else
      player.setFaceMoving(true);

    // player movement
    if (input.isKeyDown('W'.code) && input.isKeyDown('A'.code))
      player.move(UP_LEFT);
    else if (input.isKeyDown('W'.code) && input.isKeyDown('D'.code))
      player.move(UP_RIGHT);
    else if (input.isKeyDown('S'.code) && input.isKeyDown('A'.code))
      player.move(DOWN_LEFT);
    else if (input.isKeyDown('S'.code) && input.isKeyDown('D'.code))
      player.move(DOWN_RIGHT);
    else if (input.isKeyDown('D'.code))
      player.move(RIGHT);
    else if (input.isKeyDown('A'.code))
      player.move(LEFT);
    else if (input.isKeyDown('W'.code))
      player.move(UP);
    else if (input.isKeyDown('S'.code))
      player.move(DOWN);
    else
      player.stop();

    tooltip.x = mouseX;
    tooltip.y = mouseY;
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

  public function getCurrentWeapon():WeaponType
  {
    return weapon;
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