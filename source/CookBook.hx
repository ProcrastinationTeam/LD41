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
	
	public var _recipePicker : RecipePicker;
	
	public function new(playerInventory: PlayerInventory) 
	{
		super();
		
		_backgroundSprite = new FlxSprite(0, 0);
		_backgroundSprite.loadGraphic("assets/images/bookCanvas.png", true, 96, 128, false);
		add(_backgroundSprite);
		
		_recipeList = new FlxTypedGroup<Recipe>();
		
		
		// PickList
		
		//_recipePicker = new RecipePicker(playerInventory);
		//add(_recipePicker);
		
	}
	
	public function addRecipeInBook(recipe: Recipe)
	{
		
		if (_limitRecipe < 3)
		{
			recipe.setPosition(0, 30 * _limitRecipe);
			add(recipe);
			add(recipe._name);
		}
		
		_limitRecipe++;
		
		//SAVE LE COOKBOOK
		
	}
	
	
}