package;

/**
 * ...
 * @author ...
 */
class Carrot extends IngredientEnemy 
{

	public function new(?X:Float=0, ?Y:Float=0, npcData:CdbData.Npcs) 
	{
		super(X, Y, npcData);
		
		updateHitbox();
		
		setSize(npcData.sizeX * level, npcData.sizeY * level);
		offset.set(npcData.offsetX - 2 * level, npcData.offsetY - 2* level);
	}
	
}