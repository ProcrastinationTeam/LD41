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
		
		if (FlxG.mouse.justPressed) {
			FlxG.switchState(new PlayState("Jungle", "Start"));
		}
		
		 if (FlxG.keys.justPressed.TWO  || FlxG.keys.justPressed.NUMPADTWO) {
			FlxG.switchState(new LucasPlayState());
		}
		
		if (FlxG.keys.justPressed.R && FlxG.keys.pressed.SHIFT) {
			FlxG.resetGame();
		} else if (FlxG.keys.justPressed.R) {
			FlxG.resetState();
		}
	}
}
