package states;

import assetpaths.SoundAssetsPaths.SoundAssetsPath;
import flixel.FlxState;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class GameOverState extends FlxState
{
	override public function create():Void
	{
		super.create();
		
		var text = new flixel.text.FlxText(0, 0, 0, "Game Over", 32);
		text.screenCenter();
		add(text);
		
		var pressToRestart = new FlxText();
		pressToRestart.text = "Press SPACE to play again";
		pressToRestart.screenCenter();
		pressToRestart.y = text.y + 50;
		pressToRestart.alpha = 0;
		add(pressToRestart);
		
		FlxTween.tween(pressToRestart, {alpha: 1}, 0.7, {type: FlxTween.PINGPONG, ease: FlxEase.smootherStepInOut});
		//tween = FlxTween.tween(darkSprite, {alpha: 0.5}, 0.05, {type: FlxTween.PINGPONG, ease: FlxEase.linear});
		
		FlxG.sound.play(SoundAssetsPath.gameover__ogg);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		if (FlxG.mouse.justPressed || FlxG.keys.justPressed.SPACE) {
			//FlxG.switchState(new PlayState("Kitchen_32", "Start",true,true));
			FlxG.switchState(new MenuState());
		}
		
		if (FlxG.keys.justPressed.R && FlxG.keys.pressed.SHIFT) {
			FlxG.resetGame();
		} else if (FlxG.keys.justPressed.R) {
			FlxG.resetState();
		}
	}
}
