package;

import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.text.FlxText;

/**
 * ...
 * @author ElRyoGrande
 */
class Recipe extends FlxSpriteGroup 
{
	
	public var spriteSheetSize: Int = 15;
	public var _ingredientList: FlxTypedGroup<Ingredient>; // va disparaitre
	
	public var _ingredientMap: Map<CdbData.IngredientsKind,FlxSprite>;
	public var _isFull : Bool = false;
	public var _recipeImage: String;
	public var _name: FlxText;
	public var _nbIngredient : Int = 0;

	public function new() 
	{
		super();
		_name = new FlxText(0, 0, 0, "Pot au feu", 8, true );
		
		var computedOffset = (CookBook.cWidth - (_name.text.length * _name.size)) ;
		_name.setPosition(computedOffset, 16);
		add(_name);

		_ingredientList = new FlxTypedGroup<Ingredient>();

		addIngredientToRecipe(CdbData.IngredientsKind.Carrot);
		addIngredientToRecipe(CdbData.IngredientsKind.Avocado);
		addIngredientToRecipe(CdbData.IngredientsKind.Bread);
		addIngredientToRecipe(CdbData.IngredientsKind.Chicken);
		
		
	}
	
	public function addIngredientToRecipe(ingredient: CdbData.IngredientsKind) {
		
		var spr = new FlxSprite(0,0);
		var currentIngredient = CdbData.ingredients.get(ingredient);
		spr.loadGraphic("assets/" + currentIngredient.sprite.file, true, currentIngredient.sprite.size, currentIngredient.sprite.size);
		spr.scale.set(0.5, 0.5);
		spr.setPosition(_nbIngredient * (spr.width * 0.5),  _name.y + 2 );
		spr.animation.frameIndex = currentIngredient.sprite.x + 15 * currentIngredient.sprite.y;
		_nbIngredient++;
		trace("POS : ", spr.toString());
		add(spr);
		
	}
	
	
	
	
}