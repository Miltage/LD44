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

class TwoHands extends Entity
{
  public static inline var FRAME_RATE:Int = 12;
  public static inline var RADIUS:Int = 15;
  public static inline var SPEED:Int = 400;
  public static inline var SPRITE_WIDTH:Int = 32;
  public static inline var SPRITE_HEIGHT:Int = 32;
  public static inline var GUN_HEIGHT:Int = 50;

  private var revolver:AnimatedSprite;
  private var tommy:AnimatedSprite;
  private var shotgun:AnimatedSprite;
  private var muzzleFlash:Sprite;
  private var owner:Combatant;

  private var shooting:Bool;
  private var ammo:Int;

  public function new()
  {
    super();

    faceMoving = false;
    shooting = false;

    {
      var bitmapData:BitmapData = Assets.getBitmapData("assets/revolver2.png");
      var spritesheet:Spritesheet = BitmapImporter.create(bitmapData, 8, 1, SPRITE_WIDTH, SPRITE_HEIGHT);

      spritesheet.addBehavior(new BehaviorData("0", [0], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("1", [1], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("2", [2], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("3", [3], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("4", [4], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("5", [5], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("6", [6], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("7", [7], true, FRAME_RATE));

      revolver = new AnimatedSprite(spritesheet, true);
      revolver.x = -SPRITE_WIDTH * Main.SCALE/2;
      revolver.y = -SPRITE_HEIGHT * Main.SCALE * 1.25;
      revolver.scaleX = revolver.scaleY = Main.SCALE;
      addChild(revolver);
    }

    {
      var bitmapData:BitmapData = Assets.getBitmapData("assets/tommy2.png");
      var spritesheet:Spritesheet = BitmapImporter.create(bitmapData, 8, 1, SPRITE_WIDTH, SPRITE_HEIGHT);

      spritesheet.addBehavior(new BehaviorData("0", [0], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("1", [1], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("2", [2], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("3", [3], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("4", [4], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("5", [5], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("6", [6], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("7", [7], true, FRAME_RATE));

      tommy = new AnimatedSprite(spritesheet, true);
      tommy.x = -SPRITE_WIDTH * Main.SCALE/2;
      tommy.y = -SPRITE_HEIGHT * Main.SCALE * 1.25;
      tommy.scaleX = tommy.scaleY = Main.SCALE;
      addChild(tommy);
    }

    {
      var bitmapData:BitmapData = Assets.getBitmapData("assets/shotgun2.png");
      var spritesheet:Spritesheet = BitmapImporter.create(bitmapData, 8, 1, SPRITE_WIDTH, SPRITE_HEIGHT);

      spritesheet.addBehavior(new BehaviorData("0", [0], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("1", [1], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("2", [2], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("3", [3], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("4", [4], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("5", [5], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("6", [6], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("7", [7], true, FRAME_RATE));

      shotgun = new AnimatedSprite(spritesheet, true);
      shotgun.x = -SPRITE_WIDTH * Main.SCALE/2;
      shotgun.y = -SPRITE_HEIGHT * Main.SCALE * 1.25;
      shotgun.scaleX = shotgun.scaleY = Main.SCALE;
      addChild(shotgun);
    }

    muzzleFlash = new Sprite();
    muzzleFlash.graphics.beginFill(0xFFFFFF, 1);
    muzzleFlash.graphics.drawCircle(0, 0, 20);
    muzzleFlash.visible = false;
    addChild(muzzleFlash);
  }

  override private function init()
  {
    radius = 15;
    speed = 400;
  }

  public function getOwner():Combatant
  {
    return owner;
  }

  public function setOwner(c:Combatant):Void
  {
    owner = c;
    ammo = getTotalAmmo();
  }

  override public function update(delta:Int):Void
  {
    super.update(delta);

    var rads = Math.atan2(facing.y, facing.x);
    var degs = rads / Math.PI * 180;
    if (degs < 0)
      degs += 360;
    var frame = Math.abs(Math.round(degs / (360/8))) % 8;

    muzzleFlash.visible = shooting;

    if (shooting)
      shooting = false;

    if (owner != null)
    {
      var front = owner.getOffset(0, 45);
      setTarget(front.x, front.y);
      setFacingDirection(owner.getFacingDirection().x, owner.getFacingDirection().y);

      var animation = switch (owner.getWeapon())
      {
        case REVOLVER: revolver;
        case TOMMY: tommy;
        case SHOTGUN: shotgun;
        default: null;
      }

      if (animation != null)
      {
        animation.showBehavior("" + frame);
        animation.update(delta);
      }

      revolver.visible = owner.getWeapon() == REVOLVER;
      tommy.visible = owner.getWeapon() == TOMMY;
      shotgun.visible = owner.getWeapon() == SHOTGUN;
    }
  }

  public function getAmmo():Int
  {
    return ammo;
  }

  public function setAmmo(a:Int):Void
  {
    ammo = a;
  }

  public function getTotalAmmo():Int
  {
    return switch (owner.getWeapon()) {
      case REVOLVER: 6;
      case TOMMY: 30;
      case SHOTGUN: 4;
      default: 0;
    }
  }

  public function shoot():Void
  {
    if (ammo <= 0)
      return;
    else
      ammo--;

    var barrel = getShootPosition();
    muzzleFlash.x = barrel.x - x;
    muzzleFlash.y = barrel.y - y - GUN_HEIGHT;
    shooting = true;

    velocity.x = -facing.x * 160;
    velocity.y = -facing.y * 160;
    owner.push(velocity.x/2, velocity.y/2);

    Main.getGameInstance().addBullet(this);
    if (owner.getWeapon() == SHOTGUN)
    {
      for (i in 0...5)
        Main.getGameInstance().addBullet(this);
    }
    Main.getGameInstance().addDebris(x, y, ShellDebris);
  }

  public function getShootPosition():Point
  {
    if (owner == null) return new Point(0, 0);

    var offset = switch (owner.getWeapon()) {
      case REVOLVER: 25;
      case TOMMY: 30;
      default: 0;
    }
    return new Point(x + offset * facing.x, y + offset * facing.y);
  }

  override public function getFacingDirection():Point
  {
    var deviation = switch (owner.getWeapon()) {
      case SHOTGUN: 1;
      case TOMMY: 0.6;
      case REVOLVER: 0.25;
      case NONE: 0;
    };
    var f = facing.add(new Point(Math.random() * deviation - deviation/2, Math.random() * deviation - deviation/2));
    f.normalize(1);
    return f;
  }
}