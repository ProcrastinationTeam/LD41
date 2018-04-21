package;

import Data;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;

class Player extends FlxSprite 
{
	public var maxHealth:Float = 100;
	public var currentHealt:Float = 100;
	public var speed:Float = 200;
	public var sliceDmg:Float = 10;
	public var peelDmg: Float = 10;
	public var range:Float = 5;
	public var armor:Float = 0;
	public var dmgReduction:Float = 0;
	public var aimAt:Int = 1;  //0 : Up , 1 Down, 2 Left, 3 Right
	
	
	
	public function new(?X:Float=0, ?Y:Float=0) 
	{
		super(X, Y);
		loadGraphic(AssetPaths.cook__png, true, 32, 32);
		setSize(8, 14);
		offset.set(4, 2);
		scale.set(0.5, 0.5);
		updateHitbox();
		//setFacingFlip(FlxObject.LEFT, false, false);
		//setFacingFlip(FlxObject.RIGHT, true, false);
		//animation.add("lr", [3, 4, 3, 5], 6, false);
		//animation.add("u", [6, 7, 6, 8], 6, false);
		//animation.add("d", [0, 1, 0, 2], 6, false);
		drag.x = drag.y = 1600;
		
	}
	
	private function movement():Void
	{
		var _up:Bool = false;
		var _down:Bool = false;
		var _left:Bool = false;
		var _right:Bool = false;
		
		_up = FlxG.keys.anyPressed([Z]);
		_down = FlxG.keys.anyPressed([S]);
		_left = FlxG.keys.anyPressed([Q]);
		_right = FlxG.keys.anyPressed([D]);
		
		if (_up && _down)
			_up = _down = false;
		if (_left && _right)
			_left = _right = false;
			
		if (_up || _down || _left || _right)
		{
			var mA:Float = 0;
			if (_up)
			{
				mA = -90;
				if (_left)
					mA -= 45;
				else if (_right)
					mA += 45;
				//facing = FlxObject.UP;
			}
			else if (_down)
			{
				mA = 90;
				if (_left)
					mA += 45;
				else if (_right)
					mA -= 45;
				//facing = FlxObject.DOWN;
			}
			else if (_left)
			{
				mA = 180;
				//facing = FlxObject.LEFT;
			}
			else if (_right)
			{
				mA = 0;
				//facing = FlxObject.RIGHT;
			}
				 
			velocity.set(speed, 0);
			velocity.rotate(FlxPoint.weak(0, 0), mA);
			
			//if ((velocity.x != 0 || velocity.y != 0) && touching == FlxObject.NONE)
			//{
				//switch (facing)
				//{
					//case FlxObject.LEFT, FlxObject.RIGHT:
						//animation.play("lr");
					//case FlxObject.UP:
						//animation.play("u");
					//case FlxObject.DOWN:
						//animation.play("d");
				//} 
			//}
		}
	}
	
	private function aim():Void
	{
		var _up:Bool = false;
		var _down:Bool = false;
		var _left:Bool = false;
		var _right:Bool = false;
		
		_up = FlxG.keys.anyPressed([UP]);
		_down = FlxG.keys.anyPressed([DOWN]);
		_left = FlxG.keys.anyPressed([LEFT]);
		_right = FlxG.keys.anyPressed([RIGHT]);
		
		if (_up && _down)
			_up = _down = false;
		if (_left && _right)
			_left = _right = false;
			
		if (_up || _down || _left || _right)
		{
			if (_up)
			{
				aimAt = 0;
				//facing = FlxObject.UP;
			}
			else if (_down)
			{
				aimAt = 1;
				//facing = FlxObject.DOWN;
			}
			else if (_left)
			{
				aimAt = 2;
				//facing = FlxObject.LEFT;
			}
			else if (_right)
			{
				aimAt = 3;
				//facing = FlxObject.RIGHT;
			}
		}
	}
	
	private function attack():Void
	{
		
		var _peel:Bool = false;
		var _slice:Bool = false;
		
		_peel = FlxG.keys.anyPressed([E]);
		_slice = FlxG.keys.anyPressed([SPACE]);
		
		if (_peel && _slice)
			_peel = _slice = false;
			
		//if (_peel || _slice)
		//{	 
			//
		//}
	}
	
	override public function update(elapsed:Float):Void 
	{
		movement();
		super.update(elapsed);
	}
}