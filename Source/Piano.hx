package;

class Piano extends Interactable 
{

  public function new()
  {
    super();
  }

  override public function getActionString():String
  {
    return "Play piano";
  }
  
}