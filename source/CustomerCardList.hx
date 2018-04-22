package;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

/**
 * ...
 * @author ElRyoGrande
 */
class CustomerCardList extends FlxSpriteGroup 
{

	public var _backgroundSprite 				: FlxSprite;
	public var _recipeSprite 					: FlxSprite;
	
	
	public function new() 
	{
		super();
		_recipeSprite = new FlxSprite(0, 0);
		_recipeSprite.loadGraphic("assets/images/customerTicket.png", false, 32, 32, false);
		add(_recipeSprite);
	}
}