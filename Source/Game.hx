package;

import openfl.display.Sprite;
import openfl.geom.Point;
import openfl.Lib;

import Entity;
import Player;

class Game extends Sprite
{
  private var input:InputController;
  private var player:Player;
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

    for (entity in entities)
      entity.update(delta);
  }
}