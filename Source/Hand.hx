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

class Hand extends Entity
{
  public static inline var FRAME_RATE:Int = 12;
  public static inline var RADIUS:Int = 8;
  public static inline var SPRITE_WIDTH:Int = 16;
  public static inline var SPRITE_HEIGHT:Int = 16;

  private var animation:AnimatedSprite;
  private var inverted:Bool;

  public function new(flip:Bool = false)
  {
    super();

    inverted = flip;
    speed = 8;

    {
      var bitmapData:BitmapData = Assets.getBitmapData("assets/hand.png");
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
      spritesheet.addBehavior(new BehaviorData("16", [16], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("17", [17], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("18", [18], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("19", [19], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("20", [20], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("21", [21], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("22", [22], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("23", [23], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("24", [24], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("25", [25], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("26", [26], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("27", [27], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("28", [28], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("29", [29], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("30", [30], true, FRAME_RATE));
      spritesheet.addBehavior(new BehaviorData("31", [31], true, FRAME_RATE));

      animation = new AnimatedSprite(spritesheet, true);
      animation.x = -SPRITE_WIDTH * Main.SCALE/2;
      animation.y = -SPRITE_HEIGHT * Main.SCALE * 1.25;
      animation.scaleX = animation.scaleY = Main.SCALE;
      addChild(animation);
    }

    animation.showBehavior("8");
  }

  override public function update(delta:Int):Void
  {
    super.update(delta);

    var rads = Math.atan2(facing.y, facing.x);
    var degs = rads / Math.PI * 180 - 90;
    if (degs < 0)
      degs += 360;
    var frame = Math.abs(Math.floor(degs / (360/16)));

    if (inverted)
      frame += 16;

    animation.showBehavior("" + frame);

    animation.update(delta);
  }
}