package;

import cdb.Types.ArrayRead;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

/**
 * ...
 * @author ElRyoGrande
 */
class PlayerInventory extends FlxSpriteGroup 
{
	var _numberOfInGameItems: Int;
	
	var _spriteSize :Int = 32;
	var _computedScale :Float;
	
	var _inventoryCanvas: FlxSprite;
	var _text : FlxText;
	
	var _ingredientSpriteArray: FlxSpriteGroup;
	var _ingredientArray: ArrayRead<Data.Ingredients>;
	var _ingredientMap : Map<Data.IngredientsKind,Int>;
	var _textGroup : Map<Data.IngredientsKind,FlxText>;

	
	
	var nb: Int = 0;
	
	public function new(_nbTotalOfItems : Int) 
	{
		super();

		_numberOfInGameItems = Data.ingredients.all.length;
		_computedScale = (FlxG.width / _numberOfInGameItems) / _spriteSize ;
		_ingredientSpriteArray = new FlxSpriteGroup();
		_ingredientArray = Data.ingredients.all;
		_ingredientMap = new Map<Data.IngredientsKind,Int>();
		
		this.setPosition(0, 0);
		_inventoryCanvas = new FlxSprite(0, 0);
		_inventoryCanvas.loadGraphic("assets/images/inventoryBorder.png", false, 32, 32, false);
		
		
		_textGroup = new Map<Data.IngredientsKind,FlxText>();

		
		
		for (ingredient in _ingredientArray)
		{ 	
			var toAdd = Reflect.copy(_inventoryCanvas);
			toAdd.scale.set(_computedScale, _computedScale);
			toAdd.setPosition(0 + nb * (_spriteSize * _computedScale) , 0);
			toAdd.updateHitbox();
			
			
			var spr = new FlxSprite(0 + nb * (_spriteSize * _computedScale), 0);
			spr.loadGraphic("assets/" + ingredient.sprite.file, false, _spriteSize, _spriteSize, false);
			spr.scale.set(_computedScale, _computedScale);
			spr.updateHitbox();
			
			_ingredientSpriteArray.add(spr);
			
			_text = new FlxText(spr.x + (_computedScale * spr.width - 4), spr.y + (_computedScale * spr.height - 8), 0, "0", 8);
			_text.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.GREEN, 1, 1);
			
			
			_ingredientMap.set(ingredient.name, 0);
			_textGroup.set(ingredient.name, _text);
		
			add(toAdd);
			add(spr);
			add(_text);
			
			nb++;	
		}
	}
	
	
	override public function update(elapsed: Float)
	{
		
	}
	
	public function updateValueSub(kind: Data.IngredientsKind, value : Int)
	{
		var computedValue = _ingredientMap.get(kind);
		trace(computedValue);
		
		if (computedValue - value < 0)
		{
			computedValue = 0;
		}
		else
		{
			computedValue -= value;
		}
		
		_ingredientMap.set(kind, computedValue);
		var txt = _textGroup.get(kind);
		txt.text = Std.string(computedValue);
		_textGroup.set(kind, txt);
	}
	
	
	
	public function updateValueAdd(kind: Data.IngredientsKind, value : Int)
	{
		var computedValue = _ingredientMap.get(kind);
		trace(computedValue);
		
		if (computedValue + value > 9)
		{
			computedValue = 9;
		}
		else
		{
			computedValue += value;
		}
		
		
		_ingredientMap.set(kind, computedValue);
		var txt = _textGroup.get(kind);
		txt.text = Std.string(computedValue);
		_textGroup.set(kind, txt);
	}
	
}