package;

import CdbData;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class IngredientPickup extends FlxSprite
{
	public var ingredientType 	: CdbData.IngredientsKind;
	public var tileSize			: Int 						= 32;
	public var stride 			: Int						= 15;
	
	public function new(x: Float, y: Float, ingredient:CdbData.IngredientsKind) {		
		super(x, y);
		
		var data = CdbData.ingredients.get(ingredient);
		var tileset = CdbData.levelDatas.get(LevelDatasKind.Cellar_32_1).props.getTileset(CdbData.levelDatas, data.image.file);
		
		// TODO: re use AssetPaths ?
		loadGraphic("assets/" + data.image.file, true, data.image.size, data.image.size);
		animation.frameIndex = data.image.x + data.image.y * stride; // tileset.stride
		
		ingredientType = ingredient;
		
		setSize(data.sizeX + 4, data.sizeY + 4);
		offset.set(data.offsetX - 2, data.offsetY - 2);
	}
	
	override public function kill():Void
	{
		FlxTween.tween(this, { alpha: 0, y: y - 16 }, 0.5, { ease: FlxEase.circOut, onComplete: finishKill });
	}

	private function finishKill(_):Void
	{
		super.kill();
	}
}