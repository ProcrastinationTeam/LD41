package states;

import flixel.FlxState;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.mouse.FlxMouseEventManager;

class LucasPlayState extends FlxState
{

	var gameIngredientList: FlxTypedGroup<Ingredient>;
	var cookBook: CookBook;
	var currentRecipe : Recipe;
	var inventory: PlayerInventory;
	
	override public function create():Void
	{
		super.create();
		trace('lucas');
		
		cookBook = new CookBook();
		
		var chicken = new Ingredient(100, 100, 10, "chicken", IngredientType.Meat);
		var fish = new Ingredient(150, 100, 10, "fish", IngredientType.Meat);
		var steak = new Ingredient(200, 100, 10, "steak", IngredientType.Meat);
		
		add(chicken);
		add(fish);
		add(steak);
		
		gameIngredientList = new FlxTypedGroup<Ingredient>();
		gameIngredientList.add(chicken);
		gameIngredientList.add(fish);
		gameIngredientList.add(steak);
		
		inventory = new PlayerInventory(10);
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
		
		if (FlxG.keys.justPressed.NUMPADPLUS)
		{
			
		}
		
		if (FlxG.keys.justPressed.ENTER)
		{
			cookBook.addRecipeInBook(currentRecipe);
		}
		
		if (FlxG.keys.justPressed.I)
		{
			
		}
		
		
	}
	
	public function addToRecipe(ingredient:Ingredient): Void
	{
		trace("YOLO");
	}
}
