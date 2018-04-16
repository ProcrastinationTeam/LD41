package states;

import flixel.FlxState;
import flixel.FlxG;

class GuillaumePlayState extends FlxState
{
	override public function create():Void
	{
		super.create();
		trace('guillaume');
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
