package;

/**
 * ...
 * @author ...
 */
class PlayerStatWrapper 
{
	public var maxHealth:Int = 100;
	public var currentHealth:Int = 100;
	public var speed:Float = 200;
	public var sliceDmg:Int = 40;
	public var peelDmg:Int = 40;
	public var range:Float = 5;
	public var armor:Float = 0;
	public var dmgReduction:Float = 0;
	public var atckSpeed:Float = 0.5;
	public var atckDuration:Float = 0.2;
	public var isAlive:Bool = true;
	
	public var knockBackFactor:Float = 2;
	public var enemyKnockBackFactor:Float = 1;
	
	public var nbInvincibilityFrame:Int = 30;
	
	public var money:Int = 0;
	
	public function new():Void
	{
		
	}
	
	public function reset() 
	{
		maxHealth = 100;
		currentHealth = 100;
		speed = 200;
		sliceDmg = 10;
		peelDmg = 10;
		range = 5;
		armor = 0;
		dmgReduction = 0;
		atckSpeed = 0.5;
		atckDuration = 0.2;
		isAlive = true;
		
		nbInvincibilityFrame = 30;
	}
	
}