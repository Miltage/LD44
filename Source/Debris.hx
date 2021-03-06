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

class Debris extends Sprite
{
  public static inline var FRAME_RATE:Int = 1;
  public static inline var SPRITE_WIDTH:Int = 16;
  public static inline var SPRITE_HEIGHT:Int = 16;
  public static inline var RADIUS:Int = 20;

  private var animation:AnimatedSprite;
  private var container:Sprite;
  private var velocity:Point;
  private var z:Float;
  private var flagged:Bool;
  private var lifetime:Int;
  private var lifeSpan:Int;
  private var radius:Int;
  private var shadowRadius:Int;
  private var flashesOnDespawn:Bool;

  public function new()
  {
    super();

    container = new Sprite();
    addChild(container);

    velocity = new Point(Math.random() * 10 - 5, Math.random() * 10 - 5);
    z = -5;

    setHeight(30);

    lifetime = 0;
    lifeSpan = 200;
    radius = RADIUS;
    shadowRadius = RADIUS;
    flashesOnDespawn = true;

    init();

    graphics.beginFill(0, 0.7);
    graphics.drawEllipse(-shadowRadius/2, -shadowRadius/4, shadowRadius, shadowRadius/2);
  }

  public function setHeight(z:Int):Void
  {
    container.y = -z;
  }

  public function setVelocity(vx:Float, vy:Float):Void
  {
    velocity.setTo(vx, vy);
  }

  public function setArgs(args:Array<Dynamic>):Void
  {

  }

  private function init():Void
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
    animation.y = -SPRITE_HEIGHT * Main.SCALE/2;
    animation.scaleX = animation.scaleY = Main.SCALE;
    container.addChild(animation);
    container.rotation = 90;

    animation.showBehavior(""+Math.floor(Math.random() * 32));
  }

  public function update(delta:Int):Void
  {
    x += velocity.x;
    y += velocity.y;

    if (Math.abs(z) > 1)
      container.y += z;

    z += 0.5;

    if (container.y >= 0)
    {
      z = -z * 0.5;
      container.y = 0;
    }

    velocity.x *= 0.95;
    velocity.y *= 0.95;

    lifetime++;

    visible = !flashesOnDespawn || lifetime < lifeSpan * 0.9 || Math.sin(lifetime/2) > 0;

    if (lifetime >= lifeSpan)
      flagged = true;

    if (y - radius/2 < 300) y = 300 + radius/2;
  }

  public function flag():Void
  {
    flagged = true;
  }

  public function flaggedForRemoval():Bool
  {
    return flagged;
  }

  public function isDropped():Bool
  {
    return container.y >= 0;
  }
}