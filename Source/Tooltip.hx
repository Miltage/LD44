package;

import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import openfl.text.TextFieldAutoSize;

class Tooltip extends Sprite
{
  private var tx:TextField;
  private var tx2:TextField;

  public function new()
  {
    super();

    var format = new TextFormat("04b03", Std.int(8 * Main.SCALE), 0xffffff);
    format.align = TextFormatAlign.CENTER;

    tx = new TextField();
    tx.defaultTextFormat = format;
    tx.selectable = false;
    tx.autoSize = TextFieldAutoSize.LEFT;
    tx.embedFonts = true;

    format = new TextFormat("04b03", Std.int(8 * Main.SCALE), 0x000000);
    format.align = TextFormatAlign.CENTER;

    tx2 = new TextField();
    tx2.defaultTextFormat = format;
    tx2.selectable = false;
    tx2.autoSize = TextFieldAutoSize.LEFT;
    tx2.embedFonts = true;

    addChild(tx2);
    addChild(tx);
  }

  public function setText(t:String):Void
  {
    tx.text = t;
    tx2.text = t;
    tx.y = -tx.height*2;
    tx.x = -tx.width/2;
    tx2.x = tx.x + Main.SCALE;
    tx2.y = tx.y + Main.SCALE;
    visible = true;
  }
}