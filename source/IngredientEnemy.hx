package;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;


class IngredientEnemy extends FlxSprite  
{

	public var npcType			: CdbData.NpcsKind;
	public var npc				: CdbData.Npcs;
	public var level			: Float;
	public var nbDrop			: Int;
	public var hp				: Float;
	public var damage			: Int = 15;
	
	public var minScale			: Float = 0.5;
	public var maxScale			: Float = 2.5;
	
	public var speed:Float = 100;
	private var _brain:FSM;
	private var _actionTimer:Float;
	private var _moveDir:Float;
	public var seesPlayer:Bool = false;
	public var playerPos(default, null):FlxPoint;
	public var detectionRadius:Float = 75;
	public var invincible:Int = 0;
	public var nbInvincibilityFrame:Int = 15;
	
	public var normAwayX:Float = 0;
	public var normAwayY:Float = 0;
	public var knockBackAngle:Float = 0;
	
	public var idleTmrMin:Int = 1;
	public var idleTmrMax:Int = 4;
	
	public var attackTween:FlxTween;
	public var canAttack:Bool = true;
	public var nbAttack:Int = 2;
	public var basicAttackRange:Float = 50;
	public var attackTime:Float = 0.3;
	public var attackRecovery:Float = 1;
	
	public var attackTimer:FlxTimer;
	
	private var idleActions : Array<String> = 
	[
	  "MOVE",
	  "STAND",
	  "ATTACK",
	  "MOVE_TO_PLAYER",
	  "SPECIAL_ATTACK"
	];

	
	public var enumIdleSize:Int = 5;
	
	public var currentIdle:String;
	
	
	public function new(?X:Float=0, ?Y:Float=0, npcData: CdbData.Npcs) 
	{
		super(X, Y);
		
		loadGraphic("assets/" + npcData.image.file, true, npcData.image.size, npcData.image.size, false);
		setFacingFlip(FlxObject.LEFT, false, false);
        setFacingFlip(FlxObject.RIGHT, true, false);
		
		updateHitbox();
		
		for (anim in npcData.animations) {
			animation.add(anim.name, [for(frame in anim.frames) frame.frame.x + frame.frame.y * Tweaking.stride], anim.frameRate);
		}
		
		animation.play("idle", false, false, -1);
		
		drag.x = drag.y = 400;
		
		allowCollisions = FlxObject.ANY;
		
		npcType = npcData.id;
		npc = npcData;
		
		level = FlxG.random.float(minScale, maxScale);
		hp = npcData.healthPoints * level;
		
		setSize(npcData.sizeX, npcData.sizeY);
		offset.set(npcData.offsetX, npcData.offsetY);
		scale.set(level * npcData.scale, level * npcData.scale);
		
		
		_brain = new FSM(idle);
		_actionTimer = 0;
		playerPos = FlxPoint.get();
		attackTimer = new FlxTimer();
	}
	
	override public function draw():Void
	{
		animation.play("idle", false, false, -1);
		if ((velocity.x != 0 || velocity.y != 0 ))
		{
			if (Math.abs(velocity.x) > Math.abs(velocity.y))
			{
				if (velocity.x < 0)
					facing = FlxObject.LEFT;
				else
					facing = FlxObject.RIGHT;
			}
			else
			{
				if (velocity.y < 0)
					facing = FlxObject.UP;
				else
					facing = FlxObject.DOWN;
			}
			
			switch (facing)
			{
				case FlxObject.LEFT, FlxObject.RIGHT:
					animation.play("walk");

				case FlxObject.UP:
					animation.play("walk");

				case FlxObject.DOWN:
					animation.play("walk");
			}
			
		}
		if (invincible > 0)
			animation.play("hurt");
		super.draw();
	}
	
	public function idle():Void
	{
		//if action complete we pick a new one
		if (_actionTimer <= 0)
		{
			currentIdle = idleActions[FlxG.random.int(0, 5000)%(enumIdleSize-1)];
			_actionTimer = FlxG.random.int(idleTmrMin, idleTmrMax);
			
			_moveDir = FlxG.random.int(0, 360);
			trace(currentIdle);
		}
		if (seesPlayer)
		{
			_brain.activeState = chase;
			_actionTimer = 0;
		}
		
		switch(currentIdle)
		{
			case "MOVE":
				move(speed, _moveDir);
			case "STAND":
			case "ATTACK":
				if (canAttack)
				{
					attack(speed * 0.5, _moveDir);
				}
				
			case "MOVE_TO_PLAYER":
				playerPos.copyFrom(Storage.player1Stats.playerPos);
				moveToPlayer(speed);
			case "SPECIAL_ATTACK":
				if (canAttack)
				{
					attack(speed, _moveDir);
				}
		}
		_actionTimer -= FlxG.elapsed;
	
	}
	
	public function move(speed:Float, direction:Float):Void
	{
		velocity.set(speed, 0);
		velocity.rotate(FlxPoint.weak(), direction);
	}
	
	public function moveToPlayer(speed:Float):Void
	{
		FlxVelocity.moveTowardsPoint(this, playerPos, Std.int(speed));
	}
	
	public function attack(speed:Float, direction:Float):Void
	{
		var attackPoint:FlxPoint = new FlxPoint();
		attackPoint.set(basicAttackRange, 0);
		attackPoint.rotate(FlxPoint.weak(), direction);
		
		attackPoint.x = x + attackPoint.x;
		attackPoint.y = y + attackPoint.y;
		canAttack = false;
		FlxVelocity.moveTowardsPoint(this, attackPoint, speed, Std.int(attackTime * 1000));
		attackTimer.start(attackTime, enableAttack);
	}
	
	public function disableAttack():Void
	{
		canAttack = false;
	}
	
	public function enableAttack(t:FlxTimer):Void
	{
		canAttack = true;
		_actionTimer = 0;// attackRecovery;
	}
	
	public function takeDamage(Damage:Float, enemyPos:FlxPoint):Bool
	{
		if (invincible == 0)
		{
			invincible = nbInvincibilityFrame;
			hp -= Damage;
			if (hp <= 0)
			{
				hp = 0;
				return false;
			}
			knockBack(enemyPos);
			return this.alive;
		}
		else
			return true;
	}
	
	public function knockBack(enemyPos:FlxPoint):Void
	{
		var awayX:Float = (getGraphicMidpoint().x - enemyPos.x);
		var awayY:Float = (getGraphicMidpoint().y - enemyPos.y);
		var length:Float = Math.sqrt((awayX * awayX) + (awayY * awayY));
		
		normAwayX = awayX / length;
		normAwayY = awayY / length;
		
		knockBackAngle = Math.acos(normAwayX);
		knockBackAngle = knockBackAngle * 180 / Math.PI;
		
		if (normAwayY < 0)
			knockBackAngle *= -1;
	}
	
	public function chase():Void
	{
		////if action complete we pick a new one
		//if (_actionTimer <= 0)
		//{
			//currentIdle = idleActions[FlxG.random.int(0, idleActions.length - 1)];
			//_actionTimer = FlxG.random.int(idleTmrMin, idleTmrMax);
			//
			//_moveDir = FlxG.random.int(0, 8) * 45;
			//
		//}
		//if (seesPlayer)
		//{
			//_brain.activeState = chase;
			//_actionTimer = 0;
		//}
		//
		//switch(currentIdle)
		//{
			//case "MOVE":
				//move(speed * 0.5, _moveDir);
			//case "STAND":
			//case "ATTACK":
				//if (canAttack)
				//{
					//attack(speed, _moveDir);
				//}
				//
			//case "MOVE_TO_PLAYER":
				//var awayX:Float = (getGraphicMidpoint().x - playerPos.x);
				//var awayY:Float = (getGraphicMidpoint().y - playerPos.y);
				//var length:Float = Math.sqrt((awayX * awayX) + (awayY * awayY));
				//
				//normAwayX = awayX / length;
				//normAwayY = awayY / length;
				//
				//_moveDir = Math.acos(normAwayX);
				//_moveDir = knockBackAngle * 180 / Math.PI;
				//
				//if (normAwayY < 0)
					//_moveDir *= -1;
				//move(speed * 0.5, _moveDir);
			//case "SPECIAL_ATTACK":
				//if (canAttack)
				//{
					//attack(speed, _moveDir);
				//}
		//}
		//_actionTimer -= FlxG.elapsed;
		
		if (!seesPlayer)
		{
			_brain.activeState = idle;
		}
		else
		{
			if(invincible == 0)
				FlxVelocity.moveTowardsPoint(this, playerPos, Std.int(speed*1.5));
		}
	}
	
	public function getDrops(): Array<IngredientPickup> {
		var numberOfDrops = 1;
		nbDrop = FlxG.random.int(1, Std.int(maxScale));
		switch(nbDrop) {
			case 0:
				var numberOfDrops = 1 + (FlxG.random.bool(25) ? 1 : 0);
			case 1:
				var numberOfDrops = 1 + (FlxG.random.bool(50) ? 1 : 0);
			case 2:
				var numberOfDrops = 2;
		}
		
		var array:Array<IngredientPickup> = new Array<IngredientPickup>();
		for (i in 0...Std.int(numberOfDrops) + 1) {
			var drop = new IngredientPickup(x + FlxG.random.int( -32, 32), y + FlxG.random.int(-32, 32), npc.drop.name);
			array.push(drop);
		}
		
		return array;
	}
	
	override public function update(elapsed:Float):Void
	{
		if (invincible > 0)
			invincible--;
		_brain.update();
		
		if (invincible > nbInvincibilityFrame - 2)
		{
			velocity.set(speed * Storage.player1Stats.enemyKnockBackFactor, 0);
			velocity.rotate(FlxPoint.weak(0, 0), knockBackAngle);
		}
		
		super.update(elapsed);
	}
}