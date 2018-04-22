package;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;

/**
 * ...
 * @author ElRyoGrande
 */
class CookBook extends FlxSpriteGroup 
{
	public static inline var cWidth : Int = 96;
	public static inline var cHeight : Int = 128;
	
	public var _backgroundSprite : FlxSprite;
	public var _recipeList : FlxTypedGroup<Recipe>;
	public var _text: FlxText;
	public var _limitRecipe : Int = 0;
	
	public var _ingredientMap : Map<CdbData.IngredientsKind, FlxSprite>;
	
	public var _playerInventory : PlayerInventory;
	
	//public var _recipePicker : RecipePicker;
	
	public function new(playerInventory: PlayerInventory) 
	{
		super();
		
		_backgroundSprite = new FlxSprite(0, 0);
		_backgroundSprite.loadGraphic("assets/images/bookCanvas.png", true, 96, 128, false);
		add(_backgroundSprite);
		
		_recipeList = new FlxTypedGroup<Recipe>();
		
	}
	
	public function addRecipeInBook(recipe: Recipe)
	{
		
		if (_limitRecipe < 3)
		{
			recipe.setPosition(0, 30 * _limitRecipe);
			add(recipe);
			add(recipe._name);
			
		}
		
		//SAVE LE COOKBOOK
		switch (_limitRecipe) 
		{
			case  0:
				Storage.recipe1 =  recipe._recipeIngredientArray;
				Storage.recipe1name = recipe._name.text;
			case 1:
				Storage.recipe2 =  recipe._recipeIngredientArray;
				Storage.recipe2name = recipe._name.text;
			case 2:
				Storage.recipe3 =  recipe._recipeIngredientArray;
				Storage.recipe3name = recipe._name.text;
			default:
				
		}
		_limitRecipe++;
	
		
	}
	
	public function loadRecipe1(recipeList : Array<CdbData.IngredientsKind>)
	{
		_limitRecipe = 0;
		for (ingredient in recipeList)
		{
			trace("RECETTE " + Storage.recipe1name);
			
			var currentRecipe = new Recipe(Storage.recipe1name);
			currentRecipe.setFullRecipe(recipeList);
			currentRecipe.setPosition(0, 30 * _limitRecipe);
			add(currentRecipe);
			add(currentRecipe._name);
			
		}
		_limitRecipe++;
		
	}
	
	public function loadRecipe2(recipeList : Array<CdbData.IngredientsKind>)
	{
		_limitRecipe = 1;
		for (ingredient in recipeList)
		{
			trace("RECETTE " + Storage.recipe2name);
			
			var currentRecipe = new Recipe(Storage.recipe2name);
			currentRecipe.setFullRecipe(recipeList);
			currentRecipe.setPosition(0, 30 * _limitRecipe);
			add(currentRecipe);
			add(currentRecipe._name);
			
		}
		_limitRecipe++;
	}
	
	public function loadRecipe3(recipeList : Array<CdbData.IngredientsKind>)
	{
		_limitRecipe = 2;
		for (ingredient in recipeList)
		{
			trace("RECETTE " + Storage.recipe3name);
			
			var currentRecipe = new Recipe(Storage.recipe3name);
			currentRecipe.setFullRecipe(recipeList);
			currentRecipe.setPosition(0, 30 * _limitRecipe);
			add(currentRecipe);
			add(currentRecipe._name);
			
		}
		_limitRecipe++;
		
	}
	
	
}