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
  public static inline var SPAWN_DELAY:Float = 5000;

  private var input:InputController;
  private var player:Player;
  private var leftHand:Hand;
  private var rightHand:Hand;
  private var twoHands:TwoHands;
  private var entities:Array<Entity>;
  private var objects:Array<Interactable>;
  private var bullets:Array<Bullet>;
  private var worldBBs:Array<BB>;
  private var mobsters:Array<Mobster>;
  private var debris:Array<Debris>;

  private var container:Sprite;
  private var flashSprite:Sprite;
  private var debug:Sprite;
  private var tooltip:Tooltip;
  private var ui:UI;

  private var lastTime:Int;
  private var lastSpawn:Int;
  private var gameTime:Int;

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

    gameTime = 120 * 1000;

    entities = new Array<Entity>();
    objects = new Array<Interactable>();
    bullets = new Array<Bullet>();
    debris = new Array<Debris>();
    mobsters = new Array<Mobster>();

    container = new Sprite();
    addChild(container);

    tooltip = new Tooltip();
    addChild(tooltip);

    ui = new UI();
    addChild(ui);

    var sw = Lib.current.stage.stageWidth;
    var sh = Lib.current.stage.stageHeight;

    flashSprite = new Sprite();
    flashSprite.graphics.beginFill(0xFFFFFF, 0.8);
    flashSprite.graphics.drawRect(0, 0, sw, sh);
    flashSprite.visible = false;
    addChild(flashSprite);

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
      player.setWeapon(REVOLVER);
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
      twoHands.setOwner(player);
    }

    lastSpawn = SPAWN_DELAY;
  }

  public function onClick(mx:Float, my:Float):Void
  {
    var xx = mx - container.x;
    var yy = my - container.y;

    if (player.getWeapon() != NONE)
    {
      twoHands.shoot();
    }
  }

  public function addBullet(origin:TwoHands):Void
  {
    var dir = origin.getFacingDirection();
    var barrel = origin.getShootPosition();
    var bullet = new Bullet(origin, barrel.x, barrel.y, dir.x, dir.y);
    container.addChild(bullet);
    bullets.push(bullet);
  }

  public function addDebris(x:Float, y:Float, c:Class<Dynamic>, a:Array<Dynamic> = null):Debris
  {
    if (c == null) return null;
    var d = cast(Type.createInstance(c, []), Debris);
    if (a != null)
      d.setArgs(a);
    d.x = x;
    d.y = y;
    container.addChild(cast d);
    debris.push(cast d);
    return d;
  }

  public function spawnMobster():Void
  {
    var sw = Lib.current.stage.stageWidth;
    var sh = Lib.current.stage.stageHeight;

    var d = 1000;
    var angle = Math.random() * 180;
    var rads = angle / 180 * Math.PI;
    var mx = Math.cos(rads);
    var my = Math.sin(rads);

    var mobster = new Mobster();
    mobster.x = sw / 2 + mx * d;
    mobster.y = sh / 2 + my * d;
    container.addChild(mobster);
    entities.push(mobster);
    mobsters.push(mobster);

    var hands = new TwoHands();
    hands.setOwner(mobster);
    hands.x = mobster.x;
    hands.y = mobster.y;
    container.addChild(hands);
    entities.push(hands);

    mobster.setHands(hands);

    mobster.onDeath = function()
    {
      entities.remove(hands);
      container.removeChild(hands);

      addDebris(mobster.x, mobster.y, Debris);
      addDebris(mobster.x, mobster.y, Debris);
      addDebris(mobster.x, mobster.y, switch (mobster.getWeapon())
        {
          case TOMMY: WeaponDebrisTommy;
          case REVOLVER: WeaponDebrisRevolver;
          default: null;
        }, [mobster.getAmmo()]);
    }
  }

  private function discardWeapon():Void
  {
    if (player.getWeapon() == NONE) return;

    var gun = addDebris(player.x, player.y, switch (player.getWeapon())
        {
          case TOMMY: WeaponDebrisTommy;
          case REVOLVER: WeaponDebrisRevolver;
          default: null;
        }, [twoHands.getAmmo()]);

    gun.setVelocity(player.getFacingDirection().x * 10, player.getFacingDirection().y * 10);
    player.setWeapon(NONE);
  }

  public function update():Void
  {
    var time = Lib.getTimer();
    var delta = time - lastTime;
    lastTime = time;

    gameTime -= delta;

    if (time - lastSpawn > SPAWN_DELAY)
    {
      spawnMobster();
      lastSpawn = time + SPAWN_DELAY + Math.round(Math.random() * SPAWN_DELAY * 0.25);
    }

    var sw = Lib.current.stage.stageWidth;
    var sh = Lib.current.stage.stageHeight;

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

    // keep hands at player's sides
    var left = player.getOffset(-60, 30);
    leftHand.setTarget(left.x, left.y);
    var right = player.getOffset(60, 30);
    rightHand.setTarget(right.x, right.y);
    var front = player.getOffset(0, 45);
    twoHands.setTarget(front.x, front.y);

    // show correct weapon
    leftHand.visible = player.getWeapon() == NONE;
    rightHand.visible = player.getWeapon() == NONE;
    twoHands.visible = player.getWeapon() != NONE;

    if (player.getWeapon() != NONE)
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

    if (input.isKeyPressed('E'.code))
      discardWeapon();

    tooltip.x = mouseX;
    tooltip.y = mouseY;
    flashSprite.visible = false;

    for (entity in entities)
      entity.update(delta);

    for (deb in debris)
    {
      deb.update(delta);

      if (Std.is(deb, Interactable))
        cast(deb, Interactable).handleCursor(mouseX, mouseY, tooltip);

      if(deb.flaggedForRemoval())
      {
        container.removeChild(deb);
        debris.remove(deb);
      }

      if (player.getWeapon() == NONE && Std.is(deb, Interactable) && deb.isDropped())
      {
        var dx = player.x - deb.x;
        var dy = player.y - deb.y;
        var dist = Math.sqrt(dx*dx + dy*dy);

        if (dist < Player.RADIUS * 2)
        {
          var d = cast(deb, Interactable);
          player.setWeapon(d.getWeaponType());
          twoHands.setAmmo(d.getAmmo());
          deb.flag();
          break;
        }
      }
    }

    for (object in objects)
      object.handleCursor(mouseX, mouseY, tooltip);

    for (bullet in bullets)
    {
      bullet.update(delta);

      if (bullet.flaggedForRemoval() || bullet.x > sw || bullet.x < 0 || bullet.y > sh || bullet.y < 0)
      {
        bullets.remove(bullet);
        container.removeChild(bullet);
      }

      bullet.doHitDetection(entities);
    }

    for (mobster in mobsters)
    {
      if (mobster.flaggedForRemoval())
      {
        container.removeChild(mobster);
        entities.remove(mobster);
        mobsters.remove(mobster);
      }
    }

    ui.setTime(Math.floor(gameTime/1000));
    ui.setAmmo(twoHands.getAmmo());
    ui.setAmmoVisible(player.getWeapon() != NONE);
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

    return list;
  }

  public function getPlayer():Player
  {
    return player;
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
  }

  public function flash():Void
  {
    flashSprite.visible = true;
  }
}