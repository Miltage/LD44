package;

import openfl.geom.Point;

interface Combatant {
  public function getWeapon():WeaponType;
  public function setWeapon(w:WeaponType):Void;
  public function getOffset(angle:Float, dist:Float):Point;
  public function getFacingDirection():Point;
}