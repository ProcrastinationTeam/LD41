package;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import flixel.math.FlxVelocity;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

/**
 * ...
 * @author ...
 */
class Leek extends IngredientEnemy 
{
	public var tween:FlxTween;
	
	public function new(?X:Float=0, ?Y:Float=0, npcData:CdbData.Npcs) 
	{
		super(X, Y, npcData);
		//tween = new FlxTween();	
	}
	
	override public function specialAttack(speed:Float, direction:Float):Void
	{
		//var attackPoint:FlxPoint = new FlxPoint();
		//attackPoint.set(basicAttackRange, 0);
		//attackPoint.rotate(FlxPoint.weak(), direction);
		
		//attackPoint.x = x + attackPoint.x * basicAttackRange;
		//attackPoint.y = y + attackPoint.y * basicAttackRange;
		canAttack = false;
		
		//FlxVelocity.moveTowardsPoint(this, attackPoint, speed, Std.int(attackTime * 1000));
		//var vec:FlxVector = new FlxVector();
		//vec.x = attackPoint.x;
		//vec.y = attackPoint.y - 3;
		//vec.normalize();
		//fire(getPosition(), vec);
		//attackTimer.start(attackTime, enableAttack);
		//FlxTween.linearMotion(this, x, y, x + (x - X) * playerStats.knockBackFactor, y + (y - Y) * playerStats.knockBackFactor, duration, true, { type: FlxTween.ONESHOT, ease: FlxEase.expoOut});
		//tween = FlxTween.circularMotion(this, playerPos.x + (vec.x* 25), playerPos.y + (vec.x* 25), 50, 180+90, true, 1.5, { onComplete: completeAttack, type: FlxTween.ONESHOT, ease: FlxEase.expoInOut});
		tween = FlxTween.circularMotion(this, x, y, 50, 0, true, 1.5, { onComplete: completeAttack, type: FlxTween.ONESHOT, ease: FlxEase.expoInOut});
	}
	
	public function completeAttack(_):Void
	{
		canAttack = true;
	}
	
	//override public function update(elapsed:Float):Void 
	//{
		//fireBall.setPosition(x + 20, y);
		//super.update(elapsed);
	//}
}