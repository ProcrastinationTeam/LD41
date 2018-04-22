package;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

/**
 * ...
 * @author ElRyoGrande
 */
class CustomerCard extends FlxSpriteGroup 
{
	
	public var _backgroundSprite 				: FlxSprite;
	public var _recipeSprite 					: FlxSprite;
	public var _recipe							: Recipe;
	
	public function new(recipe : Recipe) 
	{
		super();
		_recipe = recipe;
		_backgroundSprite = new FlxSprite(0, 0);
		_backgroundSprite.loadGraphic("assets/images/customerTicket.png", false, 32, 32, false);
		add(_backgroundSprite);
		
		_recipeSprite = new FlxSprite(5, 5);
		_recipeSprite.loadGraphic("assets/images/assiette.png", false, 32, 32, false);
		add(_recipeSprite);
	}
	
}