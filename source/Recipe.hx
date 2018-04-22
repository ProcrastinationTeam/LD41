package;

import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.text.FlxText;

/**
 * ...
 * @author ElRyoGrande
 */
class Recipe extends FlxSpriteGroup 
{
	
	public var spriteSheetSize: Int = 15;
	
	public var _ingredientMap: Map<CdbData.IngredientsKind,FlxSprite>;
	public var _isFull : Bool = false;
	public var _recipeImage: String;
	public var _name: FlxText;
	public var _nbIngredient : Int = 0;
	
	public var _recipeIngredientArray: Array<CdbData.IngredientsKind>;

	public function new(name:String) 
	{
		super();
		_name = new FlxText(0, 0, 0, name, 8, true );
		
		var computedOffset = FlxMath.absInt(CookBook.cWidth - (_name.text.length * _name.size)) ;
		trace("OFFSET: " + computedOffset);
		_name.setPosition(computedOffset, 16);
		add(_name);

		_recipeIngredientArray =  new Array<CdbData.IngredientsKind>();
		
	}
	
	public function addIngredientToRecipe(ingredient: CdbData.IngredientsKind) {
		
		var currentIngredient = CdbData.ingredients.get(ingredient);
		_recipeIngredientArray.push(currentIngredient.name);
		
		var spr = new FlxSprite(0,0);
		spr.loadGraphic("assets/" + currentIngredient.image.file, true, currentIngredient.image.size, currentIngredient.image.size);
		spr.scale.set(0.5, 0.5);
		spr.setPosition(_nbIngredient * (spr.width * 0.5),  _name.y + 2 );
		spr.animation.frameIndex = currentIngredient.image.x + 15 * currentIngredient.image.y;
		
		_nbIngredient++;
		add(spr);
		
	}
	
	
	
	
}