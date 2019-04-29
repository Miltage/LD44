package;

import openfl.display.Sprite;
import openfl.display.BitmapData;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import openfl.text.TextFieldAutoSize;
import openfl.Lib;
import openfl.Assets;

import spritesheet.AnimatedSprite;
import spritesheet.Spritesheet;
import spritesheet.data.BehaviorData;
import spritesheet.importers.BitmapImporter;

class UI extends Sprite
{
  private var tx:TextField;
  private var tx2:TextField;
  private var hp:AnimatedSprite;

  public function new()
  {
    super();

    var sw = Lib.current.stage.stageWidth;
    var sh = Lib.current.stage.stageHeight;

    var format = new TextFormat("04b03", Std.int(12 * Main.SCALE), 0xffffff);
    format.align = TextFormatAlign.CENTER;

    tx = new TextField();
    tx.defaultTextFormat = format;
    tx.selectable = false;
    tx.autoSize = TextFieldAutoSize.LEFT;
    tx.embedFonts = true;
    tx.x = 10;
    tx.y = 10;
    addChild(tx);

    tx2 = new TextField();
    tx2.defaultTextFormat = format;
    tx2.selectable = false;
    tx2.autoSize = TextFieldAutoSize.RIGHT;
    tx2.embedFonts = true;
    tx2.y = 10;
    addChild(tx2);

    var bitmapData:BitmapData = Assets.getBitmapData("assets/hp.png");
    var spritesheet:Spritesheet = BitmapImporter.create(bitmapData, 1, 11, 96, 16);

    spritesheet.addBehavior(new BehaviorData("0", [0], true, 1));
    spritesheet.addBehavior(new BehaviorData("1", [1], true, 1));
    spritesheet.addBehavior(new BehaviorData("2", [2], true, 1));
    spritesheet.addBehavior(new BehaviorData("3", [3], true, 1));
    spritesheet.addBehavior(new BehaviorData("4", [4], true, 1));
    spritesheet.addBehavior(new BehaviorData("5", [5], true, 1));
    spritesheet.addBehavior(new BehaviorData("6", [6], true, 1));
    spritesheet.addBehavior(new BehaviorData("7", [7], true, 1));
    spritesheet.addBehavior(new BehaviorData("8", [8], true, 1));
    spritesheet.addBehavior(new BehaviorData("9", [9], true, 1));
    spritesheet.addBehavior(new BehaviorData("10", [10], true, 1));

    hp = new AnimatedSprite(spritesheet, true);
    hp.scaleX = hp.scaleY = Main.SCALE;
    addChild(hp);
    hp.y = 12;
    hp.x = sw/2 - 96/2;

    setHealthPercent(40);
  }

  public function setTime(seconds:Int):Void
  {
    tx.text = Math.floor(seconds/60) + ":" + (seconds % 60 < 10 ? "0" : "") + seconds % 60;
  }

  public function setAmmo(ammo:Int):Void
  {
    var sw = Lib.current.stage.stageWidth;
    tx2.text = "" + ammo;
    tx2.x = sw - tx2.width - 10;
  }

  public function setAmmoVisible(v:Bool):Void
  {
    tx2.visible = v;
  }

  public function setHealthPercent(percent:Float):Void
  {
    if (percent < 0)
      percent = 0;
    else if (percent > 100)
      percent = 100;

    hp.showBehavior(""+Math.floor(percent/10));
    hp.update(1);
  }
}