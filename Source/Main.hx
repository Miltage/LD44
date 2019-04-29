package;

import openfl.display.Sprite;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.display.StageQuality;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.Lib;
import openfl.Assets;

class Main extends Sprite
{
  public static inline var SCALE:Float = 2;
  public static inline var BG_COLOR:UInt = 0x342f38;

  private static var game:Game;
  private static var soundManager:SoundManager;

  private var input:InputController;
  private var frame:Int;
  private var screens:Array<Bitmap>;
  
  public function new()
  {
    super();

    input = new InputController();

    var sw = Lib.current.stage.stageWidth;
    var sh = Lib.current.stage.stageHeight;

    soundManager = new SoundManager(0.5);
    //soundManager.loop("assets/mafia.ogg");

    game = new Game(input);
    game.graphics.beginFill(BG_COLOR, 1);
    game.graphics.drawRect(0, 0, sw, sh);

    frame = 0;
    screens = new Array<Bitmap>();

    var assets = ["screen1.png", "screen2.png", "screen3.png", "howto.png"];
    for (filename in assets)
    {
      var bitmapData:BitmapData = Assets.getBitmapData("assets/"+filename);
      var screen = new Bitmap(bitmapData);
      screen.scaleX = screen.scaleY = SCALE;
      addChild(screen);
      screens.push(screen);
      screen.visible = false;
    }

    screens[0].visible = true;

    var stage = Lib.current.stage;
    stage.quality = StageQuality.LOW;
    stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
    stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
    stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
    stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
    stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
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

  private function onMouseDown(e:MouseEvent):Void
  {
    game.onMouseDown(mouseX, mouseY);
  }

  private function onMouseUp(e:MouseEvent):Void
  {
    game.onMouseUp(mouseX, mouseY);

    frame++;

    for (screen in screens)
      screen.visible = false;

    if (frame < screens.length)
      screens[frame].visible = true;
    else if (frame == screens.length)
    {
      game.init();
      addChild(game);
    }
  }

  private function onEnterFrame(e:Event):Void
  {
    game.update();
    input.update();
  }

  public static function getGameInstance():Game
  {
    return game;
  }
  
  
}