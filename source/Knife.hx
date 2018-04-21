package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;

class Knife extends FlxSprite 
{
	public var spriteResolution: Int = 32;
	public var maxHealth:Float = 100;
	public var currentHealt:Float = 100;
	public var speed:Float = 200;
	public var sliceDmg:Float = 10;
	public var dmg: Float = 10;
	public var range:Float = 5;
	public var armorPen:Float = 0;
	
	public function new() 
	{
		super();
		loadGraphic(AssetPaths.knife__1__0__png, true, spriteResolution, spriteResolution);
		setFacingFlip(FlxObject.RIGHT, false, false);
		setFacingFlip(FlxObject.LEFT, true, false);
		//setSize(spriteResolution-5, 10);
		//centerOffsets();
		//offset.set(0, spriteResolution/3);
		//scale.set(0.5, 0.5);
		updateHitbox();
		//animation.add("lr", [3, 4, 3, 5], 6, false);
		//animation.add("u", [6, 7, 6, 8], 6, false);
		//animation.add("d", [0, 1, 0, 2], 6, false);
		drag.x = drag.y = 1600;
		
	}
	
}