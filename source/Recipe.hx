package;

import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxAssets.FlxGraphicAsset;

/**
 * ...
 * @author ElRyoGrande
 */
class Recipe extends FlxSprite 
{
	var _ingredientList: FlxTypedGroup<Ingredient>;
	var _isFull : Bool = false;

	public function new(?X:Float=0, ?Y:Float=0) 
	{
		super(X, Y);
		_ingredientList = new FlxTypedGroup<Ingredient>();
	}
	
	public function addIngredientToRecipe(ingredient: Ingredient) {
		_ingredientList.add(ingredient);
		
	}
	
	public function submitRecipe() {
		
	}
	
	
}