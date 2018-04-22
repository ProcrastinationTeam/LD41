package states;

import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxAxes;

class MenuState extends FlxState
{
	private var credits : Array<String> = ["Made in 72h during the 41th Ludum Dare", "Art - Thomas Fantino @fantifanta", "Musics and sounds - "];
	
	override public function create():Void
	{
		super.create();
		trace('menu');
		
		var titleSprite = new FlxSprite();
		titleSprite.loadGraphic(AssetPaths.assiette__png);
		titleSprite.screenCenter(FlxAxes.XY);
		
		add(titleSprite);
		
		var pressToPlay = new FlxText();
		pressToPlay.text = "Press space to play!";
		pressToPlay.screenCenter(FlxAxes.XY);
		add(pressToPlay);
		
		FlxTween.tween(pressToPlay, {alpha: 0}, 0.7, {type: FlxTween.PINGPONG, ease: FlxEase.smoothStepInOut});
		
		var credits = new FlxText();
		credits.text = "Made in 72h for the 41th Ludum Dare";
		credits.screenCenter(FlxAxes.XY);
		
		
		
		Storage.ingredientsCount =  new Map<CdbData.IngredientsKind,Int>();
		Storage.recipe1 = new Array<CdbData.IngredientsKind>();
		Storage.recipe2 = new Array<CdbData.IngredientsKind>();
		Storage.recipe3 = new Array<CdbData.IngredientsKind>();
		
		Storage.recipe1name = null;
		Storage.recipe2name = null;
		Storage.recipe3name  = null;
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
