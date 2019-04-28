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

  public function new()
  {
    super();

    {
      var bitmapData:BitmapData = Assets.getBitmapData("assets/coin2.png");
      var spritesheet:Spritesheet = BitmapImporter.create(bitmapData, 16, 1, SPRITE_WIDTH, SPRITE_HEIGHT);

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

      animation = new AnimatedSprite(spritesheet, true);
      animation.x = -SPRITE_WIDTH * Main.SCALE/2;
      animation.y = -SPRITE_HEIGHT * Main.SCALE*0.85;
      animation.scaleX = animation.scaleY = Main.SCALE;
      addChild(animation);
    }

    faceMoving = false;
    lastFire = 0;
    hp = 4;
    weapon = Math.random() > .5 ? REVOLVER : TOMMY;

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
    super.update(delta);

    var sw = Lib.current.stage.stageWidth;
    var sh = Lib.current.stage.stageHeight;

    var rads = Math.atan2(facing.y, facing.x);
    var degs = rads / Math.PI * 180 + 90;
    if (degs < 0)
      degs += 360;
    var frame = Math.abs(Math.floor(degs / (360/16)));

    animation.showBehavior("" + frame);

    animation.update(delta);

    var player = Main.getGameInstance().getPlayer();

    var dx = player.x - x;
    var dy = player.y - y;
    var dist = Math.sqrt(dx*dx + dy*dy);

    if (y > sh + RADIUS || x < -RADIUS || x > sw + RADIUS || target == null && (dist < fightDistance - RADIUS || dist > fightDistance + (FIGHT_RADIUS_MAX - FIGHT_RADIUS_MIN)))
    {
      decideFightDistance(player);
    }

    facePoint(player.x, player.y);

    var time = Lib.getTimer();

    if (!isOnScreen())
      lastFire = time;

    if (time - lastFire > SHOOT_DELAY)
    {
      lastFire = time + Math.random() * SHOOT_DELAY * 0.25;
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

  private function fireWeapon():Void
  {
    if (hands == null)
      return;

    Main.getGameInstance().addBullet(hands);
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

  override public function takeDamage(amount:Int):Void
  {
    hp -= amount;
  }

  public function isDead():Bool
  {
    return hp <= 0;
  }
}