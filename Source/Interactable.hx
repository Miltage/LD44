package;

import openfl.display.Sprite;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.geom.Rectangle;
import openfl.geom.Point;
import openfl.Assets;

import spritesheet.AnimatedSprite;
import spritesheet.Spritesheet;
import spritesheet.data.BehaviorData;
import spritesheet.importers.BitmapImporter;

class Interactable extends Sprite 
{
  public static inline var FRAME_RATE:Int = 12;

  private var sprite:AnimatedSprite;
  private var spriteWidth:Int;
  private var spriteHeight:Int;
  private var highlight:Bitmap;
  
  public function new()
  {
    super();

    spriteWidth = 59;
    spriteHeight = 110;

    {
      var bitmapData:BitmapData = Assets.getBitmapData("assets/piano.png");
      var spritesheet:Spritesheet = BitmapImporter.create(bitmapData, 1, 1, spriteWidth, spriteHeight);

      spritesheet.addBehavior(new BehaviorData("0", [0], true, FRAME_RATE));

      sprite = new AnimatedSprite(spritesheet, true);
      sprite.x = -spriteWidth * Main.SCALE/2;
      sprite.y = -spriteHeight * Main.SCALE*0.85;
      sprite.scaleX = sprite.scaleY = Main.SCALE;
      addChild(sprite);

      sprite.showBehavior("0");

      var b = new BitmapData(spriteWidth, spriteHeight, true, 0);
      b.threshold(bitmapData, new Rectangle(0, 0, spriteWidth, spriteHeight), new Point(0, 0), ">", 0x00000000, 0xFFFFFFFF, 0xFF000000);
      highlight = new Bitmap(b);
      highlight.x = sprite.x;
      highlight.y = sprite.y;
      highlight.scaleX = highlight.scaleY = Main.SCALE;
      highlight.alpha = 0.2;
      addChild(highlight);
    }
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
    return "Example action";
  }
}