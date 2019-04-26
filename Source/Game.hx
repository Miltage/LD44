package;

import openfl.display.Sprite;
import openfl.geom.Point;
import openfl.Lib;

import Entity;
import Player;

class Game extends Sprite
{
  private var playerMap:Map<PlayerTeam, Player>;
  private var input:InputController;
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
    playerMap = new Map<PlayerTeam, Player>();
    entities = new Array<Entity>();

    container = new Sprite();
    addChild(container);

    var sw = Lib.current.stage.stageWidth;
    var sh = Lib.current.stage.stageHeight;

    {
      var player = new Player();
      playerMap.set(RED, player);
      player.x = 200;
      player.y = 100;
      container.addChild(player);
      entities.push(player);
    }

    {
      var player = new Player();
      player.x = 850;
      player.y = 150;
      playerMap.set(BLUE, player);
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
      getPlayer(RED).move(UP_LEFT);
    else if (input.isKeyDown('W'.code) && input.isKeyDown('D'.code))
      getPlayer(RED).move(UP_RIGHT);
    else if (input.isKeyDown('S'.code) && input.isKeyDown('A'.code))
      getPlayer(RED).move(DOWN_LEFT);
    else if (input.isKeyDown('S'.code) && input.isKeyDown('D'.code))
      getPlayer(RED).move(DOWN_RIGHT);
    else if (input.isKeyDown('D'.code))
      getPlayer(RED).move(RIGHT);
    else if (input.isKeyDown('A'.code))
      getPlayer(RED).move(LEFT);
    else if (input.isKeyDown('W'.code))
      getPlayer(RED).move(UP);
    else if (input.isKeyDown('S'.code))
      getPlayer(RED).move(DOWN);

    if (input.isKeyDown(38) && input.isKeyDown(37))
      getPlayer(BLUE).move(UP_LEFT);
    else if (input.isKeyDown(38) && input.isKeyDown(39))
      getPlayer(BLUE).move(UP_RIGHT);
    else if (input.isKeyDown(40) && input.isKeyDown(37))
      getPlayer(BLUE).move(DOWN_LEFT);
    else if (input.isKeyDown(40) && input.isKeyDown(39))
      getPlayer(BLUE).move(DOWN_RIGHT);
    else if (input.isKeyDown(39))
      getPlayer(BLUE).move(RIGHT);
    else if (input.isKeyDown(37))
      getPlayer(BLUE).move(LEFT);
    else if (input.isKeyDown(38))
      getPlayer(BLUE).move(UP);
    else if (input.isKeyDown(40))
      getPlayer(BLUE).move(DOWN);

    for (entity in entities)
      entity.update(delta);
  }

  public function getPlayer(team:PlayerTeam):Player
  {
    return playerMap.get(team);
  }
}