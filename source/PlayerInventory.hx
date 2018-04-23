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
	
	public var _spriteSize :Int = 32;
	public var _computedScale :Float;
	
	var _text : FlxText;
	
	var _ingredientSpriteArray: FlxSpriteGroup;
	public var _ingredientArray: ArrayRead<CdbData.Ingredients>;
	var _ingredientMap : Map<CdbData.IngredientsKind,Int>;
	var _textGroup : Map<CdbData.IngredientsKind,FlxText>;

	
	
	var nb: Int = 0;
	
	public function new(init : Bool = false) 
	{
		super();

		_numberOfInGameItems = CdbData.ingredients.all.length;
		_computedScale = (FlxG.width / _numberOfInGameItems) / _spriteSize ;
		_ingredientSpriteArray = new FlxSpriteGroup();
		_ingredientArray = CdbData.ingredients.all;
		_ingredientMap = new Map<CdbData.IngredientsKind,Int>();
		
		this.setPosition(0, 0);
		
		
		_textGroup = new Map<CdbData.IngredientsKind,FlxText>();

		
		
		for (ingredient in _ingredientArray)
		{ 	
			var toAdd = new FlxSprite(0, 0);
			toAdd.loadGraphic("assets/images/inventoryBorder.png", false, 32, 32, false);
			toAdd.scale.set(_computedScale, _computedScale);
			toAdd.setPosition(0 + nb * (_spriteSize * _computedScale) , 0);
			toAdd.updateHitbox();
			
			var spr = new FlxSprite(0 + nb * (_spriteSize * _computedScale), 0);
			spr.loadGraphic("assets/" + ingredient.image.file, true, _spriteSize, _spriteSize, false);
			spr.animation.frameIndex = ingredient.image.x + 15 * ingredient.image.y;
			spr.scale.set(_computedScale, _computedScale);
			spr.updateHitbox();
			
			_ingredientSpriteArray.add(spr);
			
			_text = new FlxText(spr.x + (_computedScale * spr.width - 4), spr.y + (_computedScale * spr.height - 8), 0, "0", 8);
			_text.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.GREEN, 1, 1);
			
			if (init)
			{
				_ingredientMap.set(ingredient.name, 0);
				Storage.ingredientsCount.set(ingredient.name, 0);
			}
			else
			{
				_ingredientMap = Storage.ingredientsCount;
			}
			
			
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

	
	public function updateValueSub(kind: CdbData.IngredientsKind, value : Int)
	{
		var computedValue = Storage.ingredientsCount.get(kind);
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
		
		
		Storage.ingredientsCount.set(kind, computedValue);
	}
	
	
	
	public function updateValueAdd(kind: CdbData.IngredientsKind, value : Int)
	{
		var computedValue = Storage.ingredientsCount.get(kind);
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
		
		Storage.ingredientsCount.set(kind, computedValue);
		trace("VALUE TO ADD :" + computedValue);
		trace("ACTUAL :" + Storage.ingredientsCount.get(kind));
	}
	
	public function loadInventory()
	{
		for (ingredient in _ingredientArray)
		{ 	
			trace("VALUE [" + ingredient.name + "] : " + Storage.ingredientsCount.get(ingredient.name));
			
			
			var txt = _textGroup.get(ingredient.name);
			txt.text = Std.string(Storage.ingredientsCount.get(ingredient.name));
			_textGroup.set(ingredient.name, txt);
		}
	}
}