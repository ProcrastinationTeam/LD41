package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;

class Peeler extends FlxSprite 
{
	public var spriteResolution: Int = 32;
	
	public var maxHealth:Float = 100;
	public var currentHealt:Float = 100;
	
	public var speed:Float = 200;
	public var sliceDmg:Float = 10;
	public var dmg: Float = 10;
	public var range:Float = 5;
	public var armorPen:Float = 0;
	
	public function new(?X:Float=0, ?Y:Float=0) 
	{
		super(X, Y);
		loadGraphic(AssetPaths.sprite_shit__png, true, spriteResolution, spriteResolution);
		animation.frameIndex = 37;
		setFacingFlip(FlxObject.RIGHT, false, false);
		setFacingFlip(FlxObject.LEFT, true, false);
		drag.x = drag.y = 1600;
		
	}
	
}