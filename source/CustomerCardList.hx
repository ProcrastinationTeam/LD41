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
	
	public var _spotToTake 						: Array<Bool>;
	public var _spotPosById						: Map<Int,Int>;
	public var _nbOfPlace						: Int =5;


	public function new(cookBook: CookBook)
	{
		super();
		_cookbook = cookBook;
		_customerArray = new Array<Customer>();
		_spotToTake = new Array<Bool>();
		_spotPosById = new Map<Int, Int>();
		var Ypos = 0;
		
		for (i in 0..._nbOfPlace)
		{
			_spotToTake[i] =  true;
			_spotPosById.set(i,	Ypos);	
			Ypos += 32;
			
		}
		
		_backgroundSprite = new FlxSprite(0, 0);
		_backgroundSprite.loadGraphic("assets/images/cardListCanvas.png", false, 32, 192, false);
		add(_backgroundSprite);





		_customerList = new FlxSpriteGroup();
		trace("STORAGE : " + Storage.customerArray.length);
		if (Storage.customerArray.length > 0)
		{
			trace("BUILDING CARD LIST");
			for (customer in Storage.customerArray)
			{
				addCustomerSpecial(customer);
			}
		}

		add(_customerList);

	}
	
	public function addCustomerSpecial(customer: Customer )
	{
		
		trace("SPOT ARRAY : " + _spotToTake);
		trace("customerArray : " + _customerArray.length);
		//ADD TO LIST
		var count = 0;
		for ( spot in _spotToTake)
		{
			if (spot)
			{
				_spotToTake[count] = false;
				var card = new CustomerCard(customer, this, _spotPosById.get(count),count,Storage.timerArray[count]);
				_customerArray.push(customer);
				_customerList.add(card);
				return;
			}
			count ++;
			trace(spot);
		}
	}
	

	public function addCustomer(customer: Customer)
	{
		
		trace("SPOT ARRAY : " + _spotToTake);
		trace("customerArray : " + _customerArray.length);
		//ADD TO LIST
		var count = 0;
		for ( spot in _spotToTake)
		{
			if (spot)
			{
				_spotToTake[count] = false;
				var card = new CustomerCard(customer,this, _spotPosById.get(count),count);
				_customerArray.push(customer);
				Storage.customerArray[count] = customer;
				_customerList.add(card);
				return;
			}
			count ++;
			trace(spot);
		}
	}
	
	public function removeCardByIdRecipe(id : Int) : Bool
	{
		var count = 0;
		for (customer in _customerArray)
		{
			trace(customer._recipeIdChoose);
			
			if (customer._recipeIdChoose == id)
			{
				_customerList.members[count] = null;
				_spotToTake[count] = true;
				#if cpp
				Storage.positionArray[count] = 0;
				#else
				Storage.positionArray[count] = null;
				#end
				//Storage.customerArray[count] = null;
				Storage.customerArray.remove(customer);
				return true;
			}
			count ++;
			
		}
		return false;
		
	}


}