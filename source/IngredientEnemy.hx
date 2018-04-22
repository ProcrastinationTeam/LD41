package;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;

class IngredientEnemy extends FlxSprite  
{

	public var npcType			: CdbData.NpcsKind;
	public var npc				: CdbData.Npcs;
	public var level			: Int;
	public var hp				: Float;
	
	public function new(?X:Float=0, ?Y:Float=0, npcData: CdbData.Npcs) 
	{
		super(X, Y);
		
		//drag.set(800, 800);
		immovable = true;
		
		loadGraphic("assets/" + npcData.image.file, true, npcData.image.size, npcData.image.size, false);
		
		for (anim in npcData.animations) {
			animation.add(anim.name, [for(frame in anim.frames) frame.frame.x + frame.frame.y * Tweaking.stride], anim.frameRate);
		}
		
		animation.play("idle", false, false, -1);
		
		allowCollisions = FlxObject.ANY;
		
		npcType = npcData.id;
		npc = npcData;
		level = FlxG.random.int(0, 2);
		switch(level) {
			case 0:
				hp = npcData.healthPoints;
				scale.set(1 * npcData.scale, 1 * npcData.scale);
			case 1:
				hp = npcData.healthPoints * 1.5;
				scale.set(1.25 * npcData.scale, 1.25 * npcData.scale);
			case 2:
				hp = npcData.healthPoints * 2;
				scale.set(1.5 * npcData.scale, 1.5 * npcData.scale);
		}
		
		setSize(npcData.sizeX, npcData.sizeY);
		offset.set(npcData.offsetX, npcData.offsetY);
	}
	
	public function getDrops(): Array<IngredientPickup> {
		var numberOfDrops = 1;
		
		switch(level) {
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
}