package;

import cdb.Types.ArrayRead;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

/**
 * ...
 * @author ElRyoGrande
 */
class PlayerInventory extends FlxSpriteGroup 
{

	var _inventoryCanvas: FlxSprite;
	var _numberOfInGameItems: Int;
	
	var _ingredientSpriteArray: FlxSpriteGroup;
	var _ingredientArray: ArrayRead<CdbData.Ingredients>;
	
	
	
	
	public function new(_nbTotalOfItems : Int) 
	{
		super();
		_numberOfInGameItems = _nbTotalOfItems;
		
		_ingredientSpriteArray = new FlxSpriteGroup();
		
		_ingredientArray = CdbData.ingredients.all;
		
		
		for (ingredient in _ingredientArray)
		{
			trace("INGRE: " + ingredient.name);
			trace("INGRE IMG: " + ingredient.sprite.file);
			
		}
		
		this.setPosition(0, 0);
		_inventoryCanvas = new FlxSprite(0, 0);
		_inventoryCanvas.loadGraphic("assets/images/inventoryBorder.png", false, 32, 32, false);
		
		for (i in 0..._numberOfInGameItems)
		{
			var toAdd = Reflect.copy(_inventoryCanvas);
			toAdd.setPosition(0 + i * 32, 0);
			add(toAdd);
		}
		
		
	}
	
}