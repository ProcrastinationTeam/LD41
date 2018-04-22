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
class RecipePicker extends FlxSpriteGroup 
{
	public var _backgroundSprite: FlxSprite;
	
	public var spriteSheetSize: Int = 15;
	
	public var _ingredientMap: Map<CdbData.IngredientsKind,FlxSprite>;
	public var _ingredientMapZ: Map<Int,CdbData.IngredientsKind>;
	public var _spriteArray: FlxSpriteGroup;
	public var _isFull : Bool = false;
	public var _recipeImage: String;
	public var _name: FlxText;
	public var _nbIngredient : Int = 0;
	public var _count : Int = 0;
	public var _yPos : Int = 96;
	public var _xPos : Int = 10;
	public var _actualID : Int = 0;
	
	public var _playerInventory : PlayerInventory;
	
	
	public var _recipeCanvas: FlxSprite;
	
	public var _computedOffset:Int;
	
	public var _cursor:FlxSprite;
	
	public var _currentRecipe: Recipe;
	public var _ingredientRecipeArray : Array<CdbData.IngredientsKind>;
	public var _cookbook:CookBook;
	

	public function new(playerInventory: PlayerInventory, cookbook : CookBook) 
	{
		super();
		
		_cookbook = cookbook;
		_ingredientRecipeArray = new Array<CdbData.IngredientsKind>();
		_playerInventory = playerInventory;
		_ingredientMap = new Map<CdbData.IngredientsKind, FlxSprite>();
		_ingredientMapZ = new Map<Int,CdbData.IngredientsKind>();
		_spriteArray = new FlxSpriteGroup();
		
		_backgroundSprite = new FlxSprite(0, 0);
		_backgroundSprite.loadGraphic(AssetPaths.recipeCanvas__png, false, 96, 128, false);
		_backgroundSprite.scale.set(2, 2);
		_backgroundSprite.updateHitbox();
		add(_backgroundSprite);
		
		for (ingredient in _playerInventory._ingredientArray)
		{
			
			var spr = new FlxSprite(0, 0);
			spr.loadGraphic("assets/" + ingredient.image.file, true, ingredient.image.size, ingredient.image.size, false);
			spr.scale.set(0.6, 0.6);
			//spr.updateHitbox();
			
			_computedOffset = Std.int(ingredient.image.size * 0.6);
			spr.setPosition(40,  _yPos );
			
			spr.animation.frameIndex = ingredient.image.x + 15 * ingredient.image.y;
			
			_name = new FlxText(70, _yPos + 9 , 0, ingredient.name.toString(), 8);
			_yPos += 12;
			_ingredientMap.set(ingredient.name, spr);
			_ingredientMapZ.set(_nbIngredient, ingredient.name);
			add(spr);
			add(_name);
			_spriteArray.add(spr);
			_nbIngredient++;
		}
		
		for (i in 0...5)
		{
			var ingredientFolder = new FlxSprite(0, 0);
			ingredientFolder.loadGraphic("assets/images/inventoryBorder.png", false, 32, 32, false);
			ingredientFolder.setPosition(16 + i * 32 ,  64);
			add(ingredientFolder);
		}
		
		
		_cursor = new FlxSprite(0, 0);
		_cursor.loadGraphic("assets/images/cursor.png", false, 32, 32, false);
		_cursor.scale.set(0.2, 0.2);
		_cursor.setPosition(20, _spriteArray.members[_actualID].y);
		add(_cursor);
		
	}
	
	public function changeCursorPos(value:Int)
	{
		if (value > 0)
		{
			if (_actualID + 1 > _nbIngredient-1)
			{
				_actualID = _nbIngredient-1;
			}
			else
			{
				_actualID++;
			}
		}
		else
		{
			if (_actualID - 1 < 0)
			{
				_actualID = 0;
			}
			else
			{
				_actualID--;
			}
			
		}
		trace("NEXT ID:" + _actualID);
		_cursor.setPosition(20, _spriteArray.members[_actualID].y);
	}
	
	public function selectIngredient()
	{
		if (_count + 1 <= 5)
		{
			var kindToAdd = _ingredientMapZ.get(_actualID);
			var sprout = _ingredientMap.get(kindToAdd);
			trace("COUNT: ", _count);
			
			var sp = new FlxSprite(0, 0);
			sp.loadGraphicFromSprite(sprout);
			
			_ingredientRecipeArray.push(kindToAdd);
			
			sp.setPosition(16 + _count * 32 ,  64);
			add(sp);
			trace("SPROUT: ", sp);
			_count++;
		}
		else
		{
			
		}
	}
	
	public function validRecipe()
	{
		_currentRecipe = new Recipe("Bouillabaisse");
		
		//_ingredientRecipeArray
		while (_ingredientRecipeArray.length != 0) 
		{
			_currentRecipe.addIngredientToRecipe(_ingredientRecipeArray.pop());
		}
		
		_cookbook.addRecipeInBook(_currentRecipe);
		
	}
	
	
	
	
	
}