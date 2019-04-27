package;

import openfl.display.Sprite;
import openfl.geom.Point;
import openfl.Lib;

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

  private var container:Sprite;

  private var lastTime:Int;

  public function new(input:InputController)
  {
    super();

    this.input = input;

    lastTime = Lib.getTimer();

    init();
  }

  public function reset():Void
  {
    removeChild(container);
    init();
  }

  private function init():Void
  {
    entities = new Array<Entity>();

    container = new Sprite();
    addChild(container);

    var sw = Lib.current.stage.stageWidth;
    var sh = Lib.current.stage.stageHeight;

    {
      player = new Player();
      player.x = 200;
      player.y = 100;
      container.addChild(player);
      entities.push(player);
    }

    {
      leftHand = new Hand(true);
      leftHand.x = 500;
      leftHand.y = 100;
      container.addChild(leftHand);
      entities.push(leftHand);
    }

    {
      rightHand = new Hand();
      rightHand.x = 500;
      rightHand.y = 100;
      container.addChild(rightHand);
      entities.push(rightHand);
    }
  }

  public function onClick(mx:Float, my:Float):Void
  {
    player.setTarget(mx, my);
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
    var left = player.getOffset(-70, 30);
    leftHand.setTarget(left.x, left.y);
    var right = player.getOffset(70, 30);
    rightHand.setTarget(right.x, right.y);
  }
}