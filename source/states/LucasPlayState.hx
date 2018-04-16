package states;

import flixel.FlxState;
import flixel.FlxG;

class LucasPlayState extends FlxState
{
	override public function create():Void
	{
		super.create();
		trace('lucas');
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		if (FlxG.keys.justPressed.R && FlxG.keys.pressed.SHIFT) {
			FlxG.resetGame();
		} else if (FlxG.keys.justPressed.R) {
			FlxG.resetState();
		}
	}
}
