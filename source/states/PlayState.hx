package states;

import flixel.FlxState;
import flixel.FlxG;

import states.GuillaumePlayState;
import states.LucasPlayState;
import states.GregouPlayState;

class PlayState extends FlxState
{
	override public function create():Void
	{
		super.create();
		trace('menu');
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
