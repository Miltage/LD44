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

class DustParticle extends Sprite
{
  public static inline var FRAME_RATE:Int = 1;
  public static inline var SPRITE_WIDTH:Int = 16;
  public static inline var SPRITE_HEIGHT:Int = 16;

  public function new()
  {
    super();

    var bitmapData:BitmapData = Assets.getBitmapData("assets/dust.png");
    var spritesheet:Spritesheet = BitmapImporter.create(bitmapData, 8, 2, SPRITE_WIDTH, SPRITE_HEIGHT);

    spritesheet.addBehavior(new BehaviorData("0", [0], true, FRAME_RATE));
    spritesheet.addBehavior(new BehaviorData("1", [1], true, FRAME_RATE));
    spritesheet.addBehavior(new BehaviorData("2", [2], true, FRAME_RATE));
    spritesheet.addBehavior(new BehaviorData("3", [3], true, FRAME_RATE));
    spritesheet.addBehavior(new BehaviorData("4", [4], true, FRAME_RATE));
    spritesheet.addBehavior(new BehaviorData("5", [5], true, FRAME_RATE));
    spritesheet.addBehavior(new BehaviorData("6", [6], true, FRAME_RATE));
    spritesheet.addBehavior(new BehaviorData("7", [7], true, FRAME_RATE));

    var animation = new AnimatedSprite(spritesheet, true);
    animation.x = -SPRITE_WIDTH * Main.SCALE/2;
    animation.y = -SPRITE_HEIGHT * Main.SCALE/2;
    animation.scaleX = animation.scaleY = Main.SCALE;
    addChild(animation);
    animation.rotation = Math.random() * 360;

    var frame = Math.floor(Math.random() * 8);

    animation.showBehavior(""+frame);
  }
}