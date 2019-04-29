package;

interface Interactable {
  public function handleCursor(mx:Float, my:Float, tooltip:Tooltip):Void;
  public function getActionString():String;
  public function getWeaponType():WeaponType;
  public function getAmmo():Int;
}