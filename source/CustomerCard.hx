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
	public var _recipeId						: Int;
	public var _customer 						: Customer;

	public function new(customer : Customer, ypos : Int )
	{
		super();
		//_recipe = recipe;
		_customer = customer;
		_backgroundSprite = new FlxSprite(0, ypos);
		_backgroundSprite.loadGraphic("assets/images/customerTicket.png", false, 32, 32, false);
		add(_backgroundSprite);


		_recipeSprite = new FlxSprite(0, ypos);

		switch (_customer._recipeIdChoose) {
			case 0:
			//_recipeSprite.loadGraphic("assets/images/assiette.png", false, 32, 32, false);
			//_recipeSprite.loadGraphic("assets/images/sprite_shit.png", true, 32, 32, false);
			_recipeSprite.loadGraphic(AssetPaths.sprite_shit__png, true, 32, 32, false);
			_recipeSprite.animation.frameIndex = 0 + 9 * 15;
			_recipeId = 0;
		case 1:
			_recipeSprite.loadGraphic(AssetPaths.sprite_shit__png, true, 32, 32, false);
			_recipeSprite.animation.frameIndex = 1 + 9 * 15;
			_recipeId = 1;
			//_recipeSprite.loadGraphic("assets/images/assiette2.png", true, 32, 32, false);
		case 2:
			_recipeSprite.loadGraphic(AssetPaths.sprite_shit__png, true, 32, 32, false);
			_recipeSprite.animation.frameIndex = 2 + 9 * 15;
			_recipeId = 2;
			//_recipeSprite.loadGraphic("assets/images/assiette3.png", true, 32, 32, false);
		}

		add(_recipeSprite);

		_cardId = customer._id;

		trace("CUSTOMER NUMBER :" + customer._id);
		trace("RECIPE CHOOSE :" + customer._recipeNameChoose);

	}

}