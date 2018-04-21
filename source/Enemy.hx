package;
import flixel.FlxObject;
import flixel.FlxSprite;

class Enemy extends FlxSprite  
{

	public var numberOfDrops : Int;
	
	public function new(?X:Float=0, ?Y:Float=0, npcData: CdbData.Npcs) 
	{
		super(X, Y);
		
		//drag.set(800, 800);
		immovable = true;
		
		loadGraphic("assets/" + npcData.image.file, true, npcData.image.size, npcData.image.size, false);
		
		for (anim in npcData.animations) {
			animation.add(anim.name, [for(frame in anim.frames) frame.frame.x + frame.frame.y * Tweaking.stride], anim.frameRate);
		}
		
		animation.play("idle");
		
		setSize(npcData.sizeX, npcData.sizeY);
		offset.set(npcData.offsetX, npcData.offsetY);
		
		allowCollisions = FlxObject.NONE;
	}
}