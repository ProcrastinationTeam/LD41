package;

import CdbData;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;

class Player extends FlxSprite 
{
	public var spriteResolution:Int = 32;
	
	public var maxHealth:Float = 100;
	public var currentHealth:Float = 100;
	public var speed:Float = 200;
	public var sliceDmg:Float = 10;
	public var peelDmg:Float = 10;
	public var range:Float = 5;
	public var armor:Float = 0;
	public var dmgReduction:Float = 0;
	public var atckSpeed:Float = 0.5;
	public var atckDuration:Float = 0.2;
	
	
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	
	public var attackTimer:FlxTimer;
	public var canAttackTimer:FlxTimer;
	public var canAttack:Bool = true;
	public var cooledDown:Bool = true;
	public var keyReleased:Bool = true;
	
	public var aimAt:Int = 1;  //0 : Up , 1 Down, 2 Left, 3 Right
	
	public var offsetValue:Int = 0;
	
	public var isAlive:Bool = true;
	
	public var weapons:Array<FlxSprite>;
	
	public var peeler:Peeler;
	public var knife:Knife;
	
	public var currentWeapon:Int = 0;
	public var keySpaceReleased:Bool = true;
	
	
	public function new(?X:Float=0, ?Y:Float=0) 
	{
		super(X, Y);
		loadGraphic(AssetPaths.cook__png, true, spriteResolution, spriteResolution);
		setSize(20, 10);
		offset.set(6, 22);
		//setFacingFlip(FlxObject.LEFT, false, false);
		//setFacingFlip(FlxObject.RIGHT, true, false);
		//animation.add("lr", [3, 4, 3, 5], 6, false);
		//animation.add("u", [6, 7, 6, 8], 6, false);
		//animation.add("d", [0, 1, 0, 2], 6, false);
		drag.x = drag.y = 1600;
		
		peeler = new Peeler();
		knife = new Knife();
		
		//weapons.insert(new Peeler());
		//weapons.insert(new Knife());
		
		//peeler.visible = false;
		//peeler.allowCollisions = FlxObject.NONE;
		//knife.visible = false;
		//knife.allowCollisions = FlxObject.NONE;
		
		addWeapon(peeler);
		addWeapon(knife);
		
		offsetValue = Std.int(spriteResolution/2) + Std.int((spriteResolution / 3));
		
		attackTimer = new FlxTimer();
		canAttackTimer = new FlxTimer();
		
	}
	
	public function addWeapon(item:FlxSprite):Void
	{
		item.visible = false;
		item.allowCollisions = FlxObject.NONE;
		weapons.insert(item);
	}
	
	private function aim():Void
	{
		if (!canAttack)
		{
			return;
		}
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
			keyReleased = false;
			if (_up)
			{
				aimAt = 0;
				facing = FlxObject.UP;
				offsetY = -offsetValue - spriteResolution/2;
				offsetX = 5;
				weapons[currentWeapon].facing = FlxObject.UP;
				weapons[currentWeapon].angle = -90;
				
				weapons[currentWeapon].setSize(10, spriteResolution - 5);
				weapons[currentWeapon].offset.set(spriteResolution / 3, 0);
			}
			else if (_down)
			{
				aimAt = 1;
				facing = FlxObject.DOWN;
				offsetY = offsetValue - spriteResolution/2;
				offsetX = 5;
				weapons[currentWeapon].facing = FlxObject.DOWN;
				weapons[currentWeapon].angle = 90;
				
				weapons[currentWeapon].setSize(10, spriteResolution - 5);
				weapons[currentWeapon].offset.set(spriteResolution / 3, 0);
			}
			else if (_left)
			{
				aimAt = 2;
				facing = FlxObject.LEFT;
				offsetX = -offsetValue -5;
				offsetY = -spriteResolution/3;
				weapons[currentWeapon].facing = FlxObject.LEFT;
				weapons[currentWeapon].angle = 0;
				
				weapons[currentWeapon].setSize(spriteResolution - 5, 10);
				weapons[currentWeapon].offset.set(0, spriteResolution / 3);
			}
			else if (_right)
			{
				aimAt = 3;
				facing = FlxObject.RIGHT;
				offsetX = offsetValue -5;
				offsetY = -spriteResolution/3;
				weapons[currentWeapon].facing = FlxObject.RIGHT;
				weapons[currentWeapon].angle = 0;
				
				weapons[currentWeapon].setSize(spriteResolution - 5, 10);
				weapons[currentWeapon].offset.set(0, spriteResolution / 3);
			}
			weapons[currentWeapon].x = this.x + offsetX;
			weapons[currentWeapon].y = this.y + offsetY;
			
			weapons[currentWeapon].visible = true;
			weapons[currentWeapon].allowCollisions = FlxObject.ANY;
			
			canAttack = false;
			cooledDown = false;
			attackTimer.start(atckDuration, attackEnd);
			canAttackTimer.start(atckSpeed, resetAttack);
		}
	}
	
	private function changeWeapon():Void
	{
		if (keySpaceReleased == false)
		{
			return;
		}
		
		
		var _change:Bool = false;
		
		_change = FlxG.keys.anyPressed([SPACE]);

		if (_change) 
		{
			keySpaceReleased = false;
			if (currentWeapon == 0)
				currentWeapon = 1;
			else
				currentWeapon = 0;
		}
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
		peeler.x = this.x + offsetX;
		peeler.y = this.y + offsetY;
		knife.x = this.x + offsetX;
		knife.y = this.y + offsetY;
	}
	
	private function resetAttack(Timer:FlxTimer):Void
	{
		cooledDown = true;
	}
	
	//private function attackEnd(_):Void
	private function attackEnd(Timer:FlxTimer):Void
	{
		peeler.visible = false;
		peeler.facing = FlxObject.RIGHT;
		knife.visible = false;
		knife.facing = FlxObject.RIGHT;
		
		knife.allowCollisions = FlxObject.NONE;
		peeler.allowCollisions = FlxObject.NONE;
	}
	
	private function aimKnife():Void
	{
		if (!canAttack)
		{
			return;
		}
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
			keyReleased = false;
			if (_up)
			{
				aimAt = 0;
				facing = FlxObject.UP;
				offsetY = -offsetValue - spriteResolution/2;
				offsetX = 5;
				knife.facing = FlxObject.UP;
				knife.angle = -90;
				
				knife.setSize(10, spriteResolution - 5);
				knife.offset.set(spriteResolution / 3, 0);
			}
			else if (_down)
			{
				aimAt = 1;
				facing = FlxObject.DOWN;
				offsetY = offsetValue - spriteResolution/2;
				offsetX = 5;
				knife.facing = FlxObject.DOWN;
				knife.angle = 90;
				
				knife.setSize(10, spriteResolution - 5);
				knife.offset.set(spriteResolution / 3, 0);
			}
			else if (_left)
			{
				aimAt = 2;
				facing = FlxObject.LEFT;
				offsetX = -offsetValue -5;
				offsetY = -spriteResolution/3;
				knife.facing = FlxObject.LEFT;
				knife.angle = 0;
				
				knife.setSize(spriteResolution - 5, 10);
				knife.offset.set(0, spriteResolution / 3);
			}
			else if (_right)
			{
				aimAt = 3;
				facing = FlxObject.RIGHT;
				offsetX = offsetValue -5;
				offsetY = -spriteResolution/3;
				knife.facing = FlxObject.RIGHT;
				knife.angle = 0;
				
				knife.setSize(spriteResolution - 5, 10);
				knife.offset.set(0, spriteResolution / 3);
			}
			knife.x = this.x + offsetX;
			knife.y = this.y + offsetY;
			
			knife.visible = true;
			knife.allowCollisions = FlxObject.ANY;
			
			canAttack = false;
			cooledDown = false;
			attackTimer.start(atckDuration, attackEnd);
			canAttackTimer.start(atckSpeed, resetAttack);
		}
	}
	
	private function aimPeeler():Void
	{
		if (!canAttack)
		{
			return;
		}
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
			keyReleased = false;
			if (_up)
			{
				aimAt = 0;
				facing = FlxObject.UP;
				offsetY = -offsetValue - spriteResolution/2;
				offsetX = 5;
				peeler.facing = FlxObject.UP;
				peeler.angle = -90;
				
				peeler.setSize(10, spriteResolution - 5);
				peeler.offset.set(spriteResolution / 3, 0);
			}
			else if (_down)
			{
				aimAt = 1;
				facing = FlxObject.DOWN;
				offsetY = offsetValue - spriteResolution/2;
				offsetX = 5;
				peeler.facing = FlxObject.DOWN;
				peeler.angle = 90;
				
				peeler.setSize(10, spriteResolution - 5);
				peeler.offset.set(spriteResolution / 3, 0);
			}
			else if (_left)
			{
				aimAt = 2;
				facing = FlxObject.LEFT;
				offsetX = -offsetValue -5;
				offsetY = -spriteResolution/3;
				peeler.facing = FlxObject.LEFT;
				peeler.angle = 0;
				
				peeler.setSize(spriteResolution - 5, 10);
				peeler.offset.set(0, spriteResolution / 3);
			}
			else if (_right)
			{
				aimAt = 3;
				facing = FlxObject.RIGHT;
				offsetX = offsetValue -5;
				offsetY = -spriteResolution/3;
				peeler.facing = FlxObject.RIGHT;
				peeler.angle = 0;
				
				peeler.setSize(spriteResolution - 5, 10);
				peeler.offset.set(0, spriteResolution / 3);
			}
			peeler.x = this.x + offsetX;
			peeler.y = this.y + offsetY;
			peeler.visible = true;
			peeler.allowCollisions = FlxObject.ANY;
			
			canAttack = false;
			cooledDown = false;
			attackTimer.start(atckDuration, attackEnd);
			canAttackTimer.start(atckSpeed, resetAttack);
		}
	}
	
	private function attack():Void
	{
	}
	
	public function takeDamage(Damage:Int):Bool
	{
		currentHealth -= Damage;
		if (currentHealth <= 0)
		{
			currentHealth = 0;
			isAlive = false;
		}
		return isAlive;
	}
	
	public function HealDamage(Heal: Int):Void
	{
		currentHealth += Heal;
		if (currentHealth >= maxHealth)
			currentHealth = maxHealth;
	}
	
	override public function update(elapsed:Float):Void 
	{
		//make sure key are released
		if (FlxG.keys.anyJustReleased([UP, DOWN, RIGHT, LEFT]))
		{
			keyReleased = true;
		}
		if (FlxG.keys.anyJustReleased([SPACE]))
		{
			keySpaceReleased = true;
		}
		if (keyReleased && cooledDown)
		{
			canAttack = true;
		}
		
		//compute player movement
		movement();
		
		changeWeapon();
		aim();
		//if (currentWeapon == 0)
		//{
			//aimPeeler();
		//}
		//else
		//{
			//aimKnife();
		//}
		
		super.update(elapsed);
	}
}