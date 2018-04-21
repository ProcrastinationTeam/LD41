package;

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
	//var _inventoryMap : Map;
	
	public function new(_nbTotalOfItems : Int) 
	{
		super();
		_numberOfInGameItems = _nbTotalOfItems;
		
		
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