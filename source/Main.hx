package;

import flixel.FlxGame;
import openfl.Assets;
import openfl.display.Sprite;
import states.MenuState;

class Main extends Sprite
{
	public function new()
	{
		super();
		
		// Init cdb
		CdbData.load(Assets.getText(AssetPaths.data__cdb));
		
		addChild(new FlxGame(400, 400, MenuState));
	}
}
