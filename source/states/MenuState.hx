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
	private var credits : Array<String> = [
		"Made in 72h during the 41th Ludum Dare", 
		"Tixier Lucas @LeRyokan - Game Design & Programming", 
		"Ambrois Guillaume (@Eponopono) - Tools & Programming", 
		"Gicquel Grégoire (@eorgrgix) - Programming", 
		"Comptier Maxime (@mcomptier) - Music & SFX", 
		"Fantino Thomas (@fantifanta) - Art"
	];
	
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
		pressToPlay.y += 50;
		add(pressToPlay);
		
		FlxTween.tween(pressToPlay, {alpha: 0}, 0.7, {type: FlxTween.PINGPONG, ease: FlxEase.smoothStepInOut});
		
		for (i in 0...credits.length) {
			var creditText = new FlxText(0, 0, 0, "", 7);
			creditText.text = credits[i];
			creditText.x = 20;
			creditText.y = 200 + 20 * i;
			//creditText.size = 8-i;
			add(creditText);
		}
		
		
		
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
