package;

import flixel.FlxGame;
import openfl.Assets;
import openfl.display.Sprite;
import states.MenuState;
import flixel.FlxG;

class Main extends Sprite
{
	public function new()
	{
		super();
		
		// Init cdb
		CdbData.load(Assets.getText(AssetPaths.data__cdb));
		
		addChild(new FlxGame(300, 300, MenuState));
		
		FlxG.sound.muteKeys = null;
		FlxG.sound.volumeUpKeys = null;
		FlxG.sound.volumeDownKeys = null;
	}
}
