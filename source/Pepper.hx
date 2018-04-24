package;
import flixel.FlxObject;
import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import flixel.math.FlxVelocity;
import flixel.util.FlxTimer;

/**
 * ...
 * @author ...
 */
class Pepper extends IngredientEnemy 
{
	public var fireBall:FireBall;
	public var fireBallAdded:Bool = false;
	public var fireballDuration:Float = 30;
	public var fireballSpeed:Float = 250;

	public function new(?X:Float=0, ?Y:Float=0, npcData:CdbData.Npcs) 
	{
		super(X, Y, npcData);
		
		fireBall = new FireBall();
		
	}
	
	override public function specialAttack(speed:Float, direction:Float):Void
	{
		var attackPoint:FlxPoint = new FlxPoint();
		attackPoint.set(basicAttackRange, 0);
		attackPoint.rotate(FlxPoint.weak(), direction);
		
		//attackPoint.x = x + attackPoint.x * basicAttackRange;
		//attackPoint.y = y + attackPoint.y * basicAttackRange;
		canAttack = false;
		//FlxVelocity.moveTowardsPoint(this, attackPoint, speed, Std.int(attackTime * 1000));
		var vec:FlxVector = new FlxVector();
		vec.x = attackPoint.x;
		vec.y = attackPoint.y - 3;
		vec.normalize();
		fire(getPosition(), vec);
		attackTimer.start(attackTime, enableAttack);
	}
	
	public function fire(startPos:FlxPoint, direction:FlxVector):Void
	{
		fireBall.x = startPos.x;
		fireBall.y = startPos.y;
		direction.normalize();
		
		canAttack = false;
		trace(direction);
		fireBall.velocity.set(direction.x * fireballSpeed, direction.y * fireballSpeed);
		var timer = new FlxTimer();
		fireBall.visible = true;
		//fireBall.angle = FlxAngle.angleBetweenPoint(this, direction, true);
		allowCollisions = FlxObject.ANY;
		timer.start(fireballDuration, endFireball);
	}
	
	public function endFireball(t:FlxTimer):Void
	{
		canAttack = true;
		fireBall.visible = false;
		allowCollisions = FlxObject.NONE;
		fireBall.velocity.set(0, 0);
	}
	
	//override public function update(elapsed:Float):Void 
	//{
		//fireBall.setPosition(x + 20, y);
		//super.update(elapsed);
	//}
}