package;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxTimer;

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
	public var _timer 							: FlxTimer;

	public function new(customer : Customer, ypos : Int ,cardId:Int, timerValue: Int = 0)
	{
		super();
		_cardId = cardId;
		_customer = customer;
		_timer = new FlxTimer();
		
		if (timerValue != 0)
		{
			_timer.start(timerValue, damagePlayer, 1);
		}
		else
		{
			_timer.start(5, damagePlayer, 1);
		}
		
		_backgroundSprite = new FlxSprite(0, ypos);
		_backgroundSprite.loadGraphic("assets/images/customerTicket.png", false, 32, 32, false);
		add(_backgroundSprite);

		_recipeSprite = new FlxSprite(0, ypos);

		switch (_customer._recipeIdChoose) {
			case 0:
			_recipeSprite.loadGraphic(AssetPaths.sprite_shit__png, true, 32, 32, false);
			_recipeSprite.animation.frameIndex = 0 + 9 * 15;

		case 1:
			_recipeSprite.loadGraphic(AssetPaths.sprite_shit__png, true, 32, 32, false);
			_recipeSprite.animation.frameIndex = 1 + 9 * 15;

		case 2:
			_recipeSprite.loadGraphic(AssetPaths.sprite_shit__png, true, 32, 32, false);
			_recipeSprite.animation.frameIndex = 2 + 9 * 15;

		}

		add(_recipeSprite);

	}
	
	override public function update(elapsed : Float)
	{
		Storage.timerArray[_cardId] = _timer.timeLeft;
	}
	
	public function damagePlayer(timer : FlxTimer)
	{
		Storage.player1Stats.currentHealth -= 1000;
	}
	
	

}