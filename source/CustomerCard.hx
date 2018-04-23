package;

import flixel.FlxG;
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
	public var _currentTime						: Int;
	
	public var _movePerFrame					: Float =0.0;

	public function new(customer : Customer, ypos : Int ,cardId:Int, timerValue: Int = 0)
	{
		super();
		_cardId = cardId;
		_customer = customer;
		_timer = new FlxTimer();
		
		if (timerValue != 0)
		{
			_currentTime = timerValue;
			_timer.start(timerValue, damagePlayer, 1);
		}
		else
		{
			_currentTime = _customer._timerLength;
			_timer.start(_customer._timerLength, damagePlayer, 1);
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
		
		
		if (Storage.positionArray[_cardId]!= null)
		{
			_movePerFrame  = Storage.positionArray[_cardId] / _currentTime;
			_movePerFrame /= 60;
		}
		else
		{
			_movePerFrame  = 32 / _currentTime;
			_movePerFrame /= 60;
		}
		
		
	}
	
	override public function update(elapsed : Float)
	{
		this.x -= _movePerFrame;
		Storage.timerArray[_cardId] = _timer.timeLeft;
		Storage.positionArray[_cardId] = this.x;
	}
	
	public function damagePlayer(timer : FlxTimer)
	{
		Storage.player1Stats.currentHealth -= 1000;
	}
	
	

}