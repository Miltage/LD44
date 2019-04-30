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
  public static inline var BG_COLOR:UInt = 0x121212;

  private static var game:Game;
  private static var soundManager:SoundManager;
  private static var mute:Bool;

  private var input:InputController;
  private var frame:Int;
  private var screens:Array<Bitmap>;
  private var dust:Array<DustParticle>;
  private var line:Sprite;
  
  public function new()
  {
    super();

    input = new InputController();

    var sw = Lib.current.stage.stageWidth;
    var sh = Lib.current.stage.stageHeight;

    graphics.beginFill(BG_COLOR, 1);
    graphics.drawRect(0, 0, sw, sh);

    soundManager = new SoundManager(0.4);
    soundManager.loop("assets/mafia.ogg");

    game = new Game(input);

    frame = 0;
    mute = false;
    screens = new Array<Bitmap>();
    dust = new Array<DustParticle>();

    var assets = ["screen1.png", "screen2.png", "screen3.png", "howto.png", "lose.png", "win.png", "fin.png"];
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

    for (i in 0...5)
    {
      var d = new DustParticle();
      addChild(d);
      dust.push(d);
    }

    line = new Sprite();
    line.graphics.lineStyle(2, 0xCCCCCC, 1);
    line.graphics.lineTo(sw, 0);
    addChild(line);

    addChild(game);

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
      case 'M'.code:
        muteGame();
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

    for (screen in screens)
      screen.visible = false;

    if (!game.isInitialized() && !game.isPlaying())
      frame++;

    if (frame >= screens.length + 1)
      frame = 0;

    if (game.isInitialized() && !game.isPlaying())
    {      
      game.visible = false;
      frame = game.isWin() ? 5 : 4;
    }

    if ((frame == 4 || frame == 5) && !game.isInitialized())
    {
      game.init();
      game.visible = true;
      soundManager.loop("assets/mafia.ogg");
    }
    else if (frame < screens.length && !game.isPlaying())
    {
      screens[frame].visible = true;
      game.unset();

      if (frame == 4)
        soundManager.play("assets/dirge.ogg");
      else
        soundManager.loop("assets/mafia.ogg");

    }
  }

  private function onEnterFrame(e:Event):Void
  {
    game.update();
    input.update();

    if (game.isInitialized() && game.isPlaying())
      return;

    var sw = Lib.current.stage.stageWidth;
    var sh = Lib.current.stage.stageHeight;

    if (frame < screens.length && Math.random() < .3)
    {
      screens[frame].x = Math.random() * 5;
      screens[frame].y = Math.random() * 5;
    }

    if (frame < screens.length)
      screens[frame].alpha = Math.random() < .3 ? 0.7 : 1;

    for (d in dust)
    {
      d.x = sw * Math.random();
      d.y = sw * Math.random();
      d.alpha = Math.random();
      d.visible = Math.random() > .5;
      d.scaleX = d.scaleY = Math.random() * 4 + 0.5;
    }

    line.y += Math.round(Math.random() * 4 - 2);

    if (line.y < 0) line.y += sh;
    else if (line.y > sh) line.y -= sh;

    if (Math.random() < .05)
      line.y = Math.random() * sh;
  }

  public static function getGameInstance():Game
  {
    return game;
  }  

  public static function muteGame()
  {
    mute = !mute;
    for (m in SoundManager.managers)
      m.transform(mute ? 0 : 1);
  }
}