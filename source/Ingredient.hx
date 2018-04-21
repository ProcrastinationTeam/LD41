package;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;

/**
 * ...
 * @author ElRyoGrande
 */
class Ingredient extends FlxSprite 
{
	// var _name: String;
	var _imagePath : String;
	
	var _type : Data.Ingredients_type;
	var _name : Data.IngredientsKind;
	
	var _valueGame : Int;
	
	
	public function new(?X:Float = 0, ?Y:Float = 0, pointValue: Int, type: Data.Ingredients_type, imagePath: String, name: Data.IngredientsKind) 
	{
		super(X, Y);
		_name = name;
		_type = type;
		_valueGame = pointValue;
		
		this.loadGraphic("assets/images/" + imagePath, true, 32, 32); 
		
	}
	
}