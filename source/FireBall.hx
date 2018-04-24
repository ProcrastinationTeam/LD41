package;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;

/**
 * ...
 * @author ...
 */
class FireBall extends FlxSprite 
{
	public var damage:Int = 5;
	public function new() 
	{
		super();
		loadGraphic(AssetPaths.sprite_shit__png, true, 32, 32);
		animation.frameIndex = 6;
		setFacingFlip(FlxObject.RIGHT, false, false);
		setFacingFlip(FlxObject.LEFT, true, false);
		//drag.x = drag.y = 1600;
		
		
		setSize(20, 10);
		offset.set(6, 16);
	}
	
	
	
}