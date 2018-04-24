package;

import CdbData;
import assetpaths.SoundAssetsPaths.SoundAssetsPath;
import flixel.math.FlxVelocity;
import flixel.system.FlxSound;
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
	
	public var playerStats:PlayerStatWrapper;	
	
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	
	public var aimDisabled:Bool = false;
	public var moveDisabled:Bool = false;
	
	public var attackTimer:FlxTimer;
	public var canAttackTimer:FlxTimer;
	public var canAttack:Bool = true;
	public var cooledDown:Bool = true;
	public var keyReleased:Bool = true;
	
	public var aimAt:Int = 1;  //0 : Up , 1 Down, 2 Left, 3 Right
	
	public var offsetValue:Int = 0;
	
	public var invincible:Int = 0;
	public var normAwayX:Float = 0;
	public var normAwayY:Float = 0;
	public var knockBackAngle:Float = 0;
	
	//public var isAlive:Bool = true;
	
	public var weapons:WeaponWrapper;
	
	public var currentWeapon:Int = 0;
	public var keySpaceReleased:Bool = true;
	public var moveKeyReleased:Bool = true;
	
	public var soundStep1 : FlxSound;
	public var soundStep2 : FlxSound;
	public var soundStep : FlxSound;
	
	public var soundSwing : FlxSound;
	
	public var soundHurt1 : FlxSound;
	public var soundHurt2 : FlxSound;
	public var soundHurt3 : FlxSound;
	
	public function new(?X:Float=0, ?Y:Float=0, ?playerID:Int=0) 
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
		
		drag.x = drag.y = 1600;
		
		setPlayerStat(playerID);
		
		weapons = new WeaponWrapper();
		
		offsetValue = Std.int(spriteResolution/2) + Std.int((spriteResolution / 3));
		
		attackTimer = new FlxTimer();
		canAttackTimer = new FlxTimer();
		
		soundStep1 = FlxG.sound.load(SoundAssetsPath.player_step_1__ogg);
		soundStep2 = FlxG.sound.load(SoundAssetsPath.player_step_2__ogg);
		
		soundSwing = FlxG.sound.load(SoundAssetsPath.player_swing__ogg, 0.5);
		
		soundHurt1 = FlxG.sound.load(SoundAssetsPath.hurt_1__ogg);
		soundHurt2 = FlxG.sound.load(SoundAssetsPath.hurt_2__ogg, 0.5);
		soundHurt3= FlxG.sound.load(SoundAssetsPath.hurt_3__ogg);
	}
	
	public function setPlayerStat(id:Int):Void
	{
		if(id == 0)
			playerStats = Storage.player1Stats;
		else
			playerStats = Storage.player1Stats;
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
		
		if (!canAttack)
		{
			if (cooledDown) {
				if (_up && cooledDown) {
					animation.play("walk_up");
				} else if (_down) {
					animation.play("walk_down");
				} else if (_left) {
					animation.play("walk_left");
				} else if (_right) {
					animation.play("walk_right");
				}
			}
			return;
		}
		
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
				offsetX = -10;
				currentWeaponSprite.facing = FlxObject.UP;
				currentWeaponSprite.angle = -90;
				
				currentWeaponSprite.setSize(10, spriteResolution - 5);
				currentWeaponSprite.offset.set(spriteResolution / 3, 0);
				
				animation.play("attack_up");
				soundSwing.play();
			}
			else if (_down)
			{
				aimAt = 1;
				facing = FlxObject.DOWN;
				offsetY = offsetValue - spriteResolution + 5;
				offsetX = -5;
				currentWeaponSprite.facing = FlxObject.DOWN;
				currentWeaponSprite.angle = 90;
				
				currentWeaponSprite.setSize(10, spriteResolution - 5);
				currentWeaponSprite.offset.set(spriteResolution / 4, 0);
				
				animation.play("attack_down");
				soundSwing.play();
			}
			else if (_left)
			{
				aimAt = 2;
				facing = FlxObject.LEFT;
				offsetX = -offsetValue -5;
				offsetY = -spriteResolution/4 + 2;
				currentWeaponSprite.facing = FlxObject.LEFT;
				currentWeaponSprite.angle = 0;
				
				currentWeaponSprite.setSize(spriteResolution - 5, 10);
				currentWeaponSprite.offset.set(0, spriteResolution / 2);
				
				animation.play("attack_left");
				soundSwing.play();
			}
			else if (_right)
			{
				aimAt = 3;
				facing = FlxObject.RIGHT;
				
				
				offsetX = offsetValue -10;
				offsetY = -spriteResolution/4 + 2;
				currentWeaponSprite.facing = FlxObject.RIGHT;
				currentWeaponSprite.angle = 0;
				
				currentWeaponSprite.setSize(spriteResolution - 5, 10);
				currentWeaponSprite.offset.set(0, spriteResolution / 2);
				
				animation.play("attack_right");
				soundSwing.play();
			}
			updateWeaponSprite(currentWeapon, facing);
			currentWeaponSprite.x = this.x + offsetX;
			currentWeaponSprite.y = this.y + offsetY;
			
			new FlxTimer().start(0.1, function(timer:FlxTimer) {
				currentWeaponSprite.visible = true;
			});
			currentWeaponSprite.allowCollisions = FlxObject.ANY;
			canAttack = false;
			cooledDown = false;
			attackTimer.start(playerStats.atckDuration, attackEnd);
			canAttackTimer.start(playerStats.atckSpeed, resetAttack);
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
		
		
		_up = FlxG.keys.anyPressed([W]);
		_down = FlxG.keys.anyPressed([A]);
		_left = FlxG.keys.anyPressed([S]);
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
				
			velocity.set(playerStats.speed, 0);
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
			if (!soundStep1.playing && !soundStep2.playing) {
				FlxG.random.bool(50) ? soundStep1.play() : soundStep2.play();
			}
			
			
		}
		weapons.update(x, y, offsetX, offsetY);
	}
	
	private function resetAttack(Timer:FlxTimer):Void
	{
		cooledDown = true;
	}
	
	private function attackEnd(Timer:FlxTimer):Void
	{
		weapons.resetAttack();
	}
	
	
	private function attack():Void
	{
	}
	
	public function takeDamage(Damage:Int, enemyPos:FlxPoint):Bool
	{
		if (invincible == 0)
		{
			var randomHurtSound = FlxG.random.int(1, 3);
			//trace(randomHurtSound);
			switch(randomHurtSound) {
				case 1:
					soundHurt1.play();
				case 2:
					soundHurt2.play();
				case 3:
					soundHurt3.play();
			}
			invincible = playerStats.nbInvincibilityFrame;
			playerStats.currentHealth -= Damage;
			if (playerStats.currentHealth <= 0)
			{
				playerStats.currentHealth = 0;
				playerStats.isAlive = false;
			}
			knockBack(enemyPos);
			return playerStats.isAlive;
		}
		else
			return true;
	}
	
	public function knockBack(enemyPos:FlxPoint):Void
	{
		var duration = 0.3;
		
		var posTowardx = x + (x - enemyPos.x);
		var posTowardy = y + (y - enemyPos.y);
		var posToward = new FlxPoint(posTowardx, posTowardy);
		
		//FlxTween.linearMotion(this, x, y, x + (x - X) * playerStats.knockBackFactor, y + (y - Y) * playerStats.knockBackFactor, duration, true, { type: FlxTween.ONESHOT, ease: FlxEase.expoOut});
		//FlxVelocity.moveTowardsPoint(this, posToward, 400);
		//velocity.set((x - X) * playerStats.knockBackFactor, (y - Y) * playerStats.knockBackFactor);
		
		var awayX:Float = (getGraphicMidpoint().x - enemyPos.x);
		var awayY:Float = (getGraphicMidpoint().y - enemyPos.y);
		var length:Float = Math.sqrt((awayX * awayX) + (awayY * awayY));
		
		normAwayX = awayX / length;
		normAwayY = awayY / length;
		
		knockBackAngle = Math.acos(normAwayX);
		knockBackAngle = knockBackAngle * 180 / Math.PI;
		
		if (normAwayY < 0)
			knockBackAngle *= -1;
		
		//trace(knockBackAngle);
	}
	
	public function HealDamage(Heal: Int):Void
	{
		playerStats.currentHealth += Heal;
		if (playerStats.currentHealth >= playerStats.maxHealth)
			playerStats.currentHealth = playerStats.maxHealth;
	}
	
	public function updateWeaponSprite(weapon:Int, facing:Int):Void
	{
		var currentWeaponSprite = weapons.getCurrent(currentWeapon);
		if (weapon == 0 && facing == FlxObject.UP)
		{
			currentWeaponSprite.animation.frameIndex = 103;// 37;
		}
		else if (weapon == 0)
		{
			currentWeaponSprite.animation.frameIndex = 103;
		}
		else if (weapon == 1 && facing == FlxObject.UP)
		{
			currentWeaponSprite.animation.frameIndex = 102;//22;
		}
		else if (weapon == 1)
		{
			currentWeaponSprite.animation.frameIndex = 102;
		}
		
	}
	
	public function getCurrentWeaponDmg():Float
	{
		if(currentWeapon == 0)
			return playerStats.peelDmg;
		else
			return playerStats.sliceDmg;
	}
	
	public function disableMovement():Void
	{
		moveDisabled = true;
	}
	
	public function enableMovement():Void
	{
		moveDisabled = false;
	}
	
	public function disableAim():Void
	{
		aimDisabled = true;
	}
	
	public function enableAim():Void
	{
		aimDisabled = true;
	}
	
	override public function update(elapsed:Float):Void 
	{
		//make sure key are released//
		//////////////////////////////
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
		if (FlxG.keys.anyJustReleased([W, A, S, D]))
		{
			moveKeyReleased = true;
		}
		if(moveKeyReleased && canAttack)
			animation.play("idle");
		/////////////////////////////
		
		
		//decrease invincibility
		if (invincible > 0)
			invincible--;
		
		//compute player movement
		if (!moveDisabled)
		{
			movement();
			if (invincible > playerStats.nbInvincibilityFrame - 2)
			{
				velocity.set(playerStats.speed * playerStats.knockBackFactor, 0);
				velocity.rotate(FlxPoint.weak(0, 0), knockBackAngle);
			}
			
		}
		
		if (!aimDisabled)
		{
			changeWeapon();
			aim();			
		}
		playerStats.playerPos.x = x;
		playerStats.playerPos.y = y;
		
		// définition de propreté
		if (invincible != 0 && animation.name != "hurt") {
			animation.play("hurt");
		}
		super.update(elapsed);
	}
}