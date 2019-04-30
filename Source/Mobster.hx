package;

import openfl.display.Sprite;
import openfl.display.BitmapData;
import openfl.geom.Point;
import openfl.Assets;
import openfl.Lib;

import spritesheet.AnimatedSprite;
import spritesheet.Spritesheet;
import spritesheet.data.BehaviorData;
import spritesheet.importers.BitmapImporter;

import Entity;

class Mobster extends Entity implements Combatant
{
  public static inline var FRAME_RATE:Int = 12;
  public static inline var RADIUS:Int = 30;
  public static inline var SPEED:Float = 200;
  public static inline var SPRITE_WIDTH:Int = 50;
  public static inline var SPRITE_HEIGHT:Int = 50;
  public static inline var FIGHT_RADIUS_MIN:Int = 200;
  public static inline var FIGHT_RADIUS_MAX:Int = 300;
  public static inline var SHOOT_DELAY:Int = 1000;

  private var animation:AnimatedSprite;
  private var fightDistance:Int;
  private var weapon:WeaponType;
  private var lastFire:Float;
  private var hands:TwoHands;
  private var hp:Int;
  private var flagged:Bool;
  private var shootDelay:Int;
  private var deathCount:Int;
  private var deathTimer:Int;

  public function new()
  {
    super();

    {
      var bitmapData:BitmapData = Assets.getBitmapData("assets/coin2.png");
      var spritesheet:Spritesheet = BitmapImporter.create(bitmapData, 16, 2, SPRITE_WIDTH, SPRITE_HEIGHT);

      spritesheet.addBehavior(new BehaviorData("0", [0], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("1", [1], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("2", [2], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("3", [3], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("4", [4], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("5", [5], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("6", [6], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("7", [7], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("8", [8], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("9", [9], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("10", [10], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("11", [11], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("12", [12], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("13", [13], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("14", [14], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("15", [15], true, FRAME_RATE));

      spritesheet.addBehavior(new BehaviorData("dead1", [22], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("dead2", [26], true, FRAME_RATE));

      animation = new AnimatedSprite(spritesheet, true);
      animation.x = -SPRITE_WIDTH * Main.SCALE/2;
      animation.y = -SPRITE_HEIGHT * Main.SCALE*0.85;
      animation.scaleX = animation.scaleY = Main.SCALE;
      container.addChild(animation);
    }

    faceMoving = false;
    flagged = false;
    lastFire = 0;
    deathCount = 0;
    deathTimer = 0;
    hp = 2;

    var gameTime = Main.getGameInstance().getGameTime() / 1000;

    weapon = Math.random() > .9 ? REVOLVER : TOMMY;

    if (gameTime < 90) weapon = Math.random() > .5 ? REVOLVER : TOMMY;

    if (gameTime < 60) weapon = Math.random() > .5 ? REVOLVER : (Math.random() > .5 ? TOMMY : SHOTGUN);

    weapon = Math.random() > .05 ? weapon : SHOTGUN;

    shootDelay = switch (weapon) {
      case TOMMY: Math.round(SHOOT_DELAY / 5);
      case SHOTGUN: Math.round(SHOOT_DELAY * 1.5);
      default: SHOOT_DELAY;
    }

    animation.showBehavior("8");

    decideFightDistance(Main.getGameInstance().getPlayer());
  }

  public function getWeapon():WeaponType
  {
    return weapon;
  }

  public function setWeapon(w:WeaponType):Void
  {
    weapon = w;
  }

  public function move(dir:MoveDirection):Void
  {
    targetVelocity = getDirection(dir);
    targetVelocity.normalize(SPEED);
  }

  public function stop():Void
  {
    targetVelocity.setTo(0, 0);
  }

  override public function update(delta:Int):Void
  {

    animation.update(delta);

    var time = Lib.getTimer();

    if (isDead())
    {
      deathTimer += delta;
      targetVelocity.setTo(0, 0);
      velocity.setTo(0, 0);
      container.rotation = facing.x > 0 ? -90 : 90;
      animation.showBehavior(facing.x > 0 ? "dead1" : "dead2");

      if (deathTimer > 100)
      {
        deathCount++;
        deathTimer = 0;
      }

      visible = deathCount < 40 || deathCount % 2 == 0;
      flagged = deathCount > 50;

      return;
    }

    super.update(delta);

    var sw = Lib.current.stage.stageWidth;
    var sh = Lib.current.stage.stageHeight;

    var rads = Math.atan2(facing.y, facing.x);
    var degs = rads / Math.PI * 180 + 90;
    if (degs < 0)
      degs += 360;
    var frame = Math.abs(Math.floor(degs / (360/16)));

    animation.showBehavior("" + frame);

    var player = Main.getGameInstance().getPlayer();

    var dx = player.x - x;
    var dy = player.y - y;
    var dist = Math.sqrt(dx*dx + dy*dy);

    if (y > sh + RADIUS || x < -RADIUS || x > sw + RADIUS || target == null && (dist < fightDistance - RADIUS || dist > fightDistance + (FIGHT_RADIUS_MAX - FIGHT_RADIUS_MIN)))
    {
      decideFightDistance(player);
    }

    facePoint(player.x, player.y);

    if (!isOnScreen())
      lastFire = time;

    if (time - lastFire > shootDelay)
    {
      lastFire = time + Math.random() * shootDelay * 0.25;

      if (Math.random() < 0.3)
        lastFire += SHOOT_DELAY;

      fireWeapon();
    }
  }

  public function setHands(h:TwoHands):Void
  {
    hands = h;
  }

  public function getHands():TwoHands
  {
    return hands;
  }

  public function getAmmo():Int
  {
    return hands.getAmmo();
  }

  private function fireWeapon():Void
  {
    if (hands == null)
      return;

    hands.shoot();
  }

  override public function collidesWith(entity:Entity):Bool
  {
    return Std.is(entity, Mobster) || Std.is(entity, Player);
  }

  private function decideFightDistance(player:Player):Void
  {
    var dx = x - player.x;
    var dy = y - player.y;
    var r = Math.atan2(dy, dx);
    var degs = r * 180 / Math.PI;

    fightDistance = Math.round(FIGHT_RADIUS_MIN + (FIGHT_RADIUS_MAX - FIGHT_RADIUS_MIN) * Math.random());

    var angle = degs + Math.random() * 90 - 45;
    var rads = angle / 180 * Math.PI;    
    var mx = Math.cos(rads);
    var my = Math.sin(rads);
    target = new Point(player.x + mx * fightDistance, player.y + my * fightDistance);
  }

  override public function takeDamage(amount:Int, fx:Float, fy:Float):Void
  {
    if (isDead())
      return;

    hp -= amount;

    if (hp <= 0)
      onDeath();

    velocity.x = fx * 2;
    velocity.y = fy * 2;
  }

  public function isDead():Bool
  {
    return hp <= 0;
  }

  public dynamic function onDeath():Void
  {

  }

  public function flaggedForRemoval():Bool
  {
    return flagged;
  }
}