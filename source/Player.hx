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
	
	public var weapons:WeaponWrapper;
	
	public var currentWeapon:Int = 0;
	public var keySpaceReleased:Bool = true;
	public var moveKeyReleased:Bool = true;
	
	
	public function new(?X:Float=0, ?Y:Float=0) 
	{
		super(X, Y);
		loadGraphic(AssetPaths.sprite_shit__png, true, spriteResolution, spriteResolution);
		animation.frameIndex = 20;
		setSize(20, 10);
		offset.set(6, 22);
		
		
		for (anim in CdbData.playerAnimations.all) {
			animation.add(anim.name.toString(), [for(frame in anim.frames) frame.frame.x + frame.frame.y * Tweaking.stride], anim.frameRate);
		}
		animation.play("idle");
		//setFacingFlip(FlxObject.LEFT, false, false);
		//setFacingFlip(FlxObject.RIGHT, true, false);
		//animation.add("lr", [3, 4, 3, 5], 6, false);
		//animation.add("u", [6, 7, 6, 8], 6, false);
		//animation.add("d", [0, 1, 0, 2], 6, false);
		drag.x = drag.y = 1600;
		
		weapons = new WeaponWrapper();
		
		offsetValue = Std.int(spriteResolution/2) + Std.int((spriteResolution / 3));
		
		attackTimer = new FlxTimer();
		canAttackTimer = new FlxTimer();
		
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
			var currentWeaponSprite = weapons.getCurrent(currentWeapon);
			keyReleased = false;
			if (_up)
			{
				aimAt = 0;
				facing = FlxObject.UP;
				offsetY = -offsetValue - spriteResolution/2;
				offsetX = 5;
				currentWeaponSprite.facing = FlxObject.UP;
				currentWeaponSprite.angle = -90;
				
				currentWeaponSprite.setSize(10, spriteResolution - 5);
				currentWeaponSprite.offset.set(spriteResolution / 3, 0);
				
				if (canAttack && keyReleased) {
					animation.play("attack_up");
				} else {
					animation.play("walk_up");
				}
			}
			else if (_down)
			{
				aimAt = 1;
				facing = FlxObject.DOWN;
				offsetY = offsetValue - spriteResolution/2;
				offsetX = 5;
				currentWeaponSprite.facing = FlxObject.DOWN;
				currentWeaponSprite.angle = 90;
				
				currentWeaponSprite.setSize(10, spriteResolution - 5);
				currentWeaponSprite.offset.set(spriteResolution / 3, 0);
				
				if (canAttack && keyReleased) {
					animation.play("attack_down");
				} else {
					animation.play("walk_down");
				}
			}
			else if (_left)
			{
				aimAt = 2;
				facing = FlxObject.LEFT;
				offsetX = -offsetValue -5;
				offsetY = -spriteResolution/3;
				currentWeaponSprite.facing = FlxObject.LEFT;
				currentWeaponSprite.angle = 0;
				
				currentWeaponSprite.setSize(spriteResolution - 5, 10);
				currentWeaponSprite.offset.set(0, spriteResolution / 3);
				
				if (canAttack && keyReleased) {
					animation.play("attack_left");
				} else {
					animation.play("walk_left");
				}
			}
			else if (_right)
			{
				aimAt = 3;
				facing = FlxObject.RIGHT;
				
				
				offsetX = offsetValue -5;
				offsetY = -spriteResolution/3;
				currentWeaponSprite.facing = FlxObject.RIGHT;
				currentWeaponSprite.angle = 0;
				
				currentWeaponSprite.setSize(spriteResolution - 5, 10);
				currentWeaponSprite.offset.set(0, spriteResolution / 3);
				
				if (canAttack && keyReleased) {
					animation.play("attack_right");
				} else {
					animation.play("walk_right");
				}
			}
			currentWeaponSprite.x = this.x + offsetX;
			currentWeaponSprite.y = this.y + offsetY;
			
			new FlxTimer().start(0.1, function(timer:FlxTimer) {
				currentWeaponSprite.visible = true;
			});
			currentWeaponSprite.allowCollisions = FlxObject.ANY;
			
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
		
		var anim = "";	
		
		if (_up || _down || _left || _right)
		{
			moveKeyReleased = false;
			var mA:Float = 0;
			if (_up)
			{
				mA = -90;
				if (_left)
					mA -= 45;
				else if (_right)
					mA += 45;
				//facing = FlxObject.UP;
				anim = "up";
			}
			else if (_down)
			{
				mA = 90;
				if (_left)
					mA += 45;
				else if (_right)
					mA -= 45;
				//facing = FlxObject.DOWN;
				
				anim = "down";
			}
			else if (_left)
			{
				mA = 180;
				//facing = FlxObject.LEFT;
				
				anim = "left";
			}
			else if (_right)
			{
				mA = 0;
				//facing = FlxObject.RIGHT;
				
				anim = "right";
			}
				 
			if(canAttack)
				animation.play("walk_" + anim);
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
		weapons.update(x, y, offsetX, offsetY);
	}
	
	private function resetAttack(Timer:FlxTimer):Void
	{
		cooledDown = true;
	}
	
	//private function attackEnd(_):Void
	private function attackEnd(Timer:FlxTimer):Void
	{
		weapons.resetAttack();
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
		
		if (FlxG.keys.anyJustReleased([Z, Q, S, D]))
		{
			moveKeyReleased = true;
		}
		
		if(moveKeyReleased && canAttack)
			animation.play("idle");
		//compute player movement
		movement();
		
		changeWeapon();
		aim();
		
		super.update(elapsed);
	}
}