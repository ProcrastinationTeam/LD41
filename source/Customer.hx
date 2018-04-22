package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;

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
	
	public function new(?X:Float=0, ?Y:Float=0, id : Int, player : CookBook, cardList: CustomerCardList) 
	{
		super(X, Y);
		
		_cardList = cardList;
		_id = id;
		var rand = FlxG.random.int(0, 2);
		//_recipeChoose = new Recipe("");
		_recipeChoose = player._recipeList.members[rand];
		trace("WOL :"  + player._recipeList.members[rand]);
		trace("RECIP:" + _recipeChoose);
	//	trace("CUSTOMER " + id +": " +_recipeChoose._name);
		
		_cardList.addCustomer(this);
		
	}
	
}