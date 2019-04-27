package;

import openfl.display.Sprite;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.display.StageQuality;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.Lib;
import openfl.Assets;

class Main extends Sprite
{
  public static inline var SCALE:Float = 2;
  
  private var game:Game;
  private var input:InputController;
  
  public function new()
  {
    super();

    input = new InputController();

    var sw = Lib.current.stage.stageWidth;
    var sh = Lib.current.stage.stageHeight;

    game = new Game(input);
    addChild(game);

    var stage = Lib.current.stage;
    stage.quality = StageQuality.LOW;
    stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
    stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
    stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
  }

  private function onKeyDown(e:KeyboardEvent):Void
  {
    var keyCode = Std.int(e.keyCode);
    switch (keyCode)
    {
      case 'R'.code:
        game.reset();
      default:
        input.onKeyDown(keyCode);
    }
    //trace(keyCode);
  }

  private function onKeyUp(e:KeyboardEvent):Void
  {
    var keyCode = Std.int(e.keyCode);
    input.onKeyUp(keyCode);
  }

  private function onEnterFrame(e:Event):Void
  {
    game.update();
    input.update();
  }
  
  
}