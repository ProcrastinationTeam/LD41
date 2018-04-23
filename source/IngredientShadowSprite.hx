package;
import flixel.FlxSprite;

class IngredientShadowSprite extends FlxSprite
{

	public var target:IngredientEnemy;
	
	public function new(target: IngredientEnemy)
	{
		super(0, 0);
		
		loadGraphic(AssetPaths.sprite_shit__png, true, 32, 32, false);
		animation.frameIndex = 107;
		
		scale.set(target.scale.x * 0.75, target.scale.y);
		
		this.target = target;
	}
	
	override public function update(elapsed:Float):Void {
		x = target.x + (target.width / 2) - 16;
		y = target.y + target.offset.y + target.height - 16;
		
		// Si on veut garder les ombres à la mort
		if (!target.alive) {
			super.kill();
		}
	}
}