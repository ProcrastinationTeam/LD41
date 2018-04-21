package;
import flixel.group.FlxGroup.FlxTypedGroup;

/**
 * ...
 * @author ElRyoGrande
 */
class CookBook 
{

	var _recipeList : FlxTypedGroup<Recipe>;
	
	public function new() 
	{
		_recipeList = new FlxTypedGroup<Recipe>();
	}
	
	public function addRecipeInBook(recipe: Recipe)
	{
		_recipeList.add(recipe);
	}
	
}