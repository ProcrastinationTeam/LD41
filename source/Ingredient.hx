package;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;

/**
 * ...
 * @author ElRyoGrande
 */
class Ingredient extends FlxSprite 
{
	var _name: String;
	var _imagePath : String;
	var _type : IngredientType;
	
	var _valueGame : Int;
	
	
	public function new(?X:Float = 0, ?Y:Float = 0, pointValue: Int, name: String, type: IngredientType) 
	{
		super(X, Y);
		_name = name;
		_type = type;
		_valueGame = pointValue;
		
		this.loadGraphic("assets/images/" + name + "_Ingredient.png", true, 32, 32); 
		
	}
	
}