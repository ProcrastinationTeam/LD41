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
	public var _customerArray					: Array<Customer>;
	public var _customerList					: FlxSpriteGroup;
	public var _cookbook 						: CookBook;



	public function new(cookBook: CookBook)
	{
		super();
		_cookbook = cookBook;
		_customerArray = new Array<Customer>();

		_backgroundSprite = new FlxSprite(0, 40);
		_backgroundSprite.loadGraphic("assets/images/cardListCanvas.png", false, 32, 192, false);
		add(_backgroundSprite);


		//_recipeSprite = new FlxSprite(0, 40);
		//_recipeSprite.loadGraphic("assets/images/customerTicket.png", false, 32, 32, false);


		_customerList = new FlxSpriteGroup();
		//_customerList.add(_recipeSprite);

		add(_customerList);

	}


	public function createCard(customer: Customer)
	{


		var card = new CustomerCard(customer);

		_customerList.add(card);
	}

	public function addCustomer(customer: Customer)
	{
		_customerArray.push(customer);
		createCard(customer);
	}



}