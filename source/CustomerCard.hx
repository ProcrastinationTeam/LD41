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
	public var _cardId							: Int;

	public function new(customer : Customer)
	{
		super();
		//_recipe = recipe;
		_backgroundSprite = new FlxSprite(0, 0);
		_backgroundSprite.loadGraphic("assets/images/customerTicket.png", false, 32, 32, false);
		add(_backgroundSprite);


		_recipeSprite = new FlxSprite(0, 0);

		switch (customer._recipeIdChoose) {
			case 0:
			_recipeSprite.loadGraphic("assets/images/assiette.png", false, 32, 32, false);
			case 1:
			_recipeSprite.loadGraphic("assets/images/assiette2.png", false, 32, 32, false);
			case 2:
			_recipeSprite.loadGraphic("assets/images/assiette3.png", false, 32, 32, false);
		}

		add(_recipeSprite);

		_cardId = customer._id;

		trace("CUSTOMER NUMBER :" + customer._id);
		trace("RECIPE CHOOSE :" + customer._recipeNameChoose);

	}

}