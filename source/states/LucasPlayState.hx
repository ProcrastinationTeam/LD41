package states;

import flixel.FlxState;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.mouse.FlxMouseEventManager;
import openfl.Assets;

class LucasPlayState extends FlxState
{

	var cookBook: CookBook;
	var currentRecipe : Recipe;
	var inventory: PlayerInventory;
	
	override public function create():Void
	{
		super.create();
		trace('lucas');
		
		inventory = new PlayerInventory();
		add(inventory);
		
		

		
		
		
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		if (FlxG.keys.justPressed.R && FlxG.keys.pressed.SHIFT) {
			FlxG.resetGame();
		} else if (FlxG.keys.justPressed.R) {
			FlxG.resetState();
		}
		
		if (FlxG.keys.justPressed.NUMPADTHREE)
		{
			inventory.updateValueSub(CdbData.IngredientsKind.Avocado, 1);
		}
		
		if (FlxG.keys.justPressed.NUMPADSIX)
		{
			inventory.updateValueAdd(CdbData.IngredientsKind.Avocado, 1);
		}
		
		if (FlxG.keys.justPressed.ENTER)
		{
			cookBook.addRecipeInBook(currentRecipe);
		}
		
		if (FlxG.keys.justPressed.I)
		{
			
		}
		
		
	}
	
	
}
