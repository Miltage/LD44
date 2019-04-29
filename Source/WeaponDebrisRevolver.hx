package;

import openfl.display.Sprite;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.Assets;
import openfl.Lib;

import spritesheet.AnimatedSprite;
import spritesheet.Spritesheet;
import spritesheet.data.BehaviorData;
import spritesheet.importers.BitmapImporter;

class WeaponDebrisRevolver extends Debris implements Interactable
{
  public static inline var FRAME_RATE:Int = 1;
  public static inline var SPRITE_WIDTH:Int = 32;
  public static inline var SPRITE_HEIGHT:Int = 32;

  private var highlight:Bitmap;
  private var ammo:Int;

  override public function setArgs(args:Array<Dynamic>):Void
  {
    ammo = Std.int(args[0]);
  }

  override private function init()
  {
    var bitmapData:BitmapData = Assets.getBitmapData("assets/revolver.png");
    var spritesheet:Spritesheet = BitmapImporter.create(bitmapData, 8, 2, SPRITE_WIDTH, SPRITE_HEIGHT);

    spritesheet.addBehavior(new BehaviorData("0", [0], true, FRAME_RATE));
    spritesheet.addBehavior(new BehaviorData("1", [1], true, FRAME_RATE));
    spritesheet.addBehavior(new BehaviorData("2", [2], true, FRAME_RATE));
    spritesheet.addBehavior(new BehaviorData("3", [3], true, FRAME_RATE));
    spritesheet.addBehavior(new BehaviorData("4", [4], true, FRAME_RATE));
    spritesheet.addBehavior(new BehaviorData("5", [5], true, FRAME_RATE));
    spritesheet.addBehavior(new BehaviorData("6", [6], true, FRAME_RATE));
    spritesheet.addBehavior(new BehaviorData("7", [7], true, FRAME_RATE));

    animation = new AnimatedSprite(spritesheet, true);
    animation.x = -SPRITE_WIDTH * Main.SCALE/2;
    animation.y = -SPRITE_HEIGHT * Main.SCALE/2;
    animation.scaleX = animation.scaleY = Main.SCALE;
    container.addChild(animation);
    container.rotation = 90;

    var frame = Math.floor(Math.random() * 8);

    animation.showBehavior(""+frame);

    var b = new BitmapData(SPRITE_WIDTH, SPRITE_HEIGHT, true, 0);
    b.threshold(bitmapData, new Rectangle(frame*SPRITE_WIDTH, 0, SPRITE_WIDTH, SPRITE_HEIGHT), new Point(0, 0), ">", 0x00000000, 0xFFFFFFFF, 0xFF000000);
    highlight = new Bitmap(b);
    highlight.x = animation.x;
    highlight.y = animation.y;
    highlight.scaleX = highlight.scaleY = Main.SCALE;
    highlight.alpha = 1;
    container.addChild(highlight);

    lifeSpan = 400;
    ammo = 0;
    radius = 50;
  }

  public function handleCursor(mx:Float, my:Float, tooltip:Tooltip):Void
  {
    var hit = hitTestPoint(mx, my);

    highlight.visible = hit;

    if (hit)
      tooltip.setText(getActionString());
  }

  public function getActionString():String
  {
    return "Revolver: "+ammo;
  }

  public function getWeaponType():WeaponType
  {
    return REVOLVER;
  }

  public function getAmmo():Int
  {
    return ammo;
  }
}