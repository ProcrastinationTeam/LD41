package states;

import flixel.FlxState;
import flixel.FlxG;

class MenuState extends FlxState
{
	override public function create():Void
	{
		super.create();
		trace('menu');
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		if (FlxG.mouse.justPressed || FlxG.keys.justPressed.SPACE) {
			FlxG.switchState(new PlayState("Kitchen_32", "Start", true, true));
		}
		
		if (FlxG.keys.justPressed.R && FlxG.keys.pressed.SHIFT) {
			FlxG.resetGame();
		} else if (FlxG.keys.justPressed.R) {
			FlxG.resetState();
		}
	}
}
