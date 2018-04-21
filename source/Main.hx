package;

import flixel.FlxGame;
import openfl.display.Sprite;
import states.MenuState;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(400, 400, MenuState));
	}
}
