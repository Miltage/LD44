package;

import openfl.Lib;

class InputController 
{
  private var keyPresses:Map<Int, Bool>;
  private var keyTimes:Map<Int, Int>;

  public function new()
  {
    reset();
  }

  public function isKeyDown(keyCode:Int):Bool
  {
    return keyPresses.exists(keyCode);
  }

  public function isKeyPressed(keyCode:Int):Bool
  {
    if (isKeyDown(keyCode) && !keyTimes.exists(keyCode))
    {
      keyTimes.set(keyCode, Lib.getTimer());
      return true;
    }
    else if (!keyTimes.exists(keyCode)) 
      return false;

    var d:Int = (Lib.getTimer() - keyTimes.get(keyCode));
    return isKeyDown(keyCode) && d > 200;
  }

  public function onKeyDown(keyCode:Int):Void
  {
    keyPresses.set(keyCode, true);
  }

  public function onKeyUp(keyCode:Int):Void
  {
    keyPresses.remove(keyCode);
  }

  public function reset():Void
  {
    keyPresses = new Map<Int, Bool>();
    keyTimes = new Map<Int, Int>();
  }

  public function update():Void
  {
    for (key in keyPresses.keys())
    {
      if (isKeyDown(key))
        keyTimes.set(key, Lib.getTimer());
    }
  }
}