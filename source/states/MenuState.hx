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
			FlxG.switchState(new PlayState("FirstVillage"));
		}
		
		if (FlxG.keys.justPressed.ONE || FlxG.keys.justPressed.NUMPADONE) {
			FlxG.switchState(new GuillaumePlayState("FirstVillage"));
		} else if (FlxG.keys.justPressed.TWO  || FlxG.keys.justPressed.NUMPADTWO) {
			FlxG.switchState(new LucasPlayState());
		} else if (FlxG.keys.justPressed.THREE  || FlxG.keys.justPressed.NUMPADTHREE) {
			FlxG.switchState(new GregouPlayState("FirstVillage"));
		}
		
		if (FlxG.keys.justPressed.R && FlxG.keys.pressed.SHIFT) {
			FlxG.resetGame();
		} else if (FlxG.keys.justPressed.R) {
			FlxG.resetState();
		}
	}
}
