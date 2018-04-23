package;
import flixel.FlxSprite;

class ShadowSprite extends FlxSprite
{

	public var target:FlxSprite;
	public var isPlayerShadow:Bool;
	
	public function new(target: FlxSprite, ?isPlayerShadow = false)
	{
		super(0, 0);
		
		loadGraphic(AssetPaths.sprite_shit__png, true, 32, 32, false);
		animation.frameIndex = 107;
		
		scale.set(target.scale.x * 0.75, target.scale.y);
		
		this.target = target;
		this.isPlayerShadow = isPlayerShadow;
	}
	
	override public function update(elapsed:Float):Void {
		if (isPlayerShadow) {
			x = target.x + (target.width / 2) - 16;
			y = target.y - 6;
		} else {
			x = target.x + (target.width / 2) - 16;
			y = target.y + target.offset.y + target.height - 16;
		}
		
		// Si on veut garder les ombres à la mort
		if (!target.alive) {
			super.kill();
		}
	}
}