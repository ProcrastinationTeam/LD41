package;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;

class IngredientEnemy extends FlxSprite  
{

	public var npcType			: CdbData.NpcsKind;
	public var npc				: CdbData.Npcs;
	public var level			: Float;
	public var nbDrop			: Int;
	public var hp				: Float;
	public var damage			: Int = 15;
	public var maxScale			: Float = 2.5;
	
	public var speed:Float = 140;
	private var _brain:FSM;
	private var _idleTmr:Float;
	private var _moveDir:Float;
	public var seesPlayer:Bool = false;
	public var playerPos(default, null):FlxPoint;
	public var detectionRadius:Float = 32;
	
	
	public function new(?X:Float=0, ?Y:Float=0, npcData: CdbData.Npcs) 
	{
		super(X, Y);
		
		//drag.set(800, 800);
		//immovable = true;
		
		loadGraphic("assets/" + npcData.image.file, true, npcData.image.size, npcData.image.size, false);
		setFacingFlip(FlxObject.LEFT, false, false);
        setFacingFlip(FlxObject.RIGHT, true, false);
		for (anim in npcData.animations) {
			animation.add(anim.name, [for(frame in anim.frames) frame.frame.x + frame.frame.y * Tweaking.stride], anim.frameRate);
		}
		
		animation.play("idle", false, false, -1);
		
		allowCollisions = FlxObject.ANY;
		
		npcType = npcData.id;
		npc = npcData;
		
		level = FlxG.random.float(0.5, maxScale);
		hp = npcData.healthPoints * level;
		scale.set(level * npcData.scale, level * npcData.scale);
		
		setSize(npcData.sizeX, npcData.sizeY);
		offset.set(npcData.offsetX, npcData.offsetY);
		
		_brain = new FSM(idle);
		_idleTmr = 0;
		playerPos = FlxPoint.get();
	}
	
	override public function draw():Void
	{
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
			
			animation.play("walk");
		}
		super.draw();
	}
	
	public function idle():Void
	{
		if (seesPlayer)
		{
			_brain.activeState = chase;
		}
		else if (_idleTmr <= 0)
		{
			if (FlxG.random.bool(1))
			{
				_moveDir = -1;
				velocity.x = velocity.y = 0;
			}
			else
			{
				_moveDir = FlxG.random.int(0, 8) * 45;
	
				velocity.set(speed * 0.5, 0);
				velocity.rotate(FlxPoint.weak(), _moveDir);
	
			}
			_idleTmr = FlxG.random.int(1, 4);            
		}
		else
			_idleTmr -= FlxG.elapsed;
	
	}
	
	public function chase():Void
	{
		if (!seesPlayer)
		{
			_brain.activeState = idle;
		}
		else
		{
			FlxVelocity.moveTowardsPoint(this, playerPos, Std.int(speed));
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
		_brain.update();
		super.update(elapsed);
	}
}