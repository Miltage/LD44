package;

import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import openfl.text.TextFieldAutoSize;
import openfl.Lib;

class UI extends Sprite
{
  private var tx:TextField;
  private var tx2:TextField;

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
  }

  public function setTime(seconds:Int):Void
  {
    tx.text = Math.floor(seconds/60) + ":" + (seconds < 10 ? "0" : "") + seconds % 60;
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
}