package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxTimer;

/**
 * ...
 * @author ElRyoGrande
 */
class Customer extends FlxSprite
{
	public var _recipeChoose : Recipe;
	public var _card : CustomerCard;
	public var _id : Int;
	public var _cardList : CustomerCardList;
	public var _recipeNameChoose : String;
	public var _recipeIdChoose: Int;
	
	public var _timerLength : Int;

	

	public function new(?X:Float=0, ?Y:Float=0, id : Int, cookbook : CookBook, cardList: CustomerCardList)
	{
		super(X, Y);

		_cardList = cardList;
		_id = id;
	
		var rand = FlxG.random.int(0, 2);
		switch (rand) {
			case 0:
				_recipeNameChoose = Storage.recipe1name;
				_timerLength = Storage.recipe1.length * 25 ;
			case 1:
				_recipeNameChoose = Storage.recipe2name;
				_timerLength = Storage.recipe2.length * 25 ;
			case 2:
				_recipeNameChoose = Storage.recipe3name;
				_timerLength = Storage.recipe3.length * 25;
			default:
		}
		_recipeIdChoose = rand;

		
		
		
		_cardList.addCustomer(this);
		
	}

	
	
}