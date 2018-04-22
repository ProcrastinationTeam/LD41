package;
import flixel.FlxObject;
import flixel.FlxSprite;

/**
 * ...
 * @author ...
 */
class WeaponWrapper 
{
	public var peeler:Peeler;
	public var knife:Knife;
	
	public function new() 
	{
		peeler = new Peeler();
		knife  = new Knife();
		peeler.visible = false;
		peeler.allowCollisions = FlxObject.NONE;
		knife.visible = false;
		knife.allowCollisions = FlxObject.NONE;
	}
	
	public function getCurrent(currentIndex:Int):FlxSprite
	{
		if(currentIndex == 0)
		{
			return peeler;
		}
		else 
		{
			return knife;
		}
	}
	
	public function resetAttack():Void
	{
		peeler.visible = false;
		peeler.facing = FlxObject.RIGHT;
		peeler.allowCollisions = FlxObject.NONE;
		
		knife.visible = false;
		knife.facing = FlxObject.RIGHT;
		knife.allowCollisions = FlxObject.NONE;
	}
	
	public function update(X:Float, Y:Float, offsetX:Float, offsetY: Float):Void
	{
		peeler.x = X + offsetX;
		peeler.y = Y + offsetY;
		knife.x = X + offsetX;
		knife.y = Y + offsetY;
	}
	
}