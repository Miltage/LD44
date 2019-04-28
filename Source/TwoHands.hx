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
  public static inline var RADIUS:Int = 8;
  public static inline var SPEED:Int = 10;
  public static inline var SPRITE_WIDTH:Int = 32;
  public static inline var SPRITE_HEIGHT:Int = 32;

  private var revolver:AnimatedSprite;
  private var tommy:AnimatedSprite;

  public function new()
  {
    super();

    faceMoving = false;

    {
      var bitmapData:BitmapData = Assets.getBitmapData("assets/revolver.png");
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
      var bitmapData:BitmapData = Assets.getBitmapData("assets/tommy.png");
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
  }

  override public function update(delta:Int):Void
  {
    super.update(delta);

    var rads = Math.atan2(facing.y, facing.x);
    var degs = rads / Math.PI * 180;
    if (degs < 0)
      degs += 360;
    var frame = Math.abs(Math.round(degs / (360/8))) % 8;

    var animation = switch (Main.getGameInstance().getCurrentWeapon())
    {
      case REVOLVER: revolver;
      case TOMMY: tommy;
      default: null;
    }

    if (animation != null)
    {
      animation.showBehavior("" + frame);
      animation.update(delta);
    }

    revolver.visible = Main.getGameInstance().getCurrentWeapon() == REVOLVER;
    tommy.visible = Main.getGameInstance().getCurrentWeapon() == TOMMY;
  }
}