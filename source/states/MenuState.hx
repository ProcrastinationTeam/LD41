package states;

import assetpaths.SoundAssetsPaths.SoundAssetsPath;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxG;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxAxes;

class MenuState extends FlxState {
	
	private var names : Array<String> = [
		"Tixier Lucas @LeRyokan",
		"Ambrois Guillaume @Eponopono",
		"Gicquel Grégoire",
		"Comptier Maxime",
		"Fantino Thomas"
	];

	private var jobs : Array<String> = [
		"Game Design & Programming",
		"Tools & Programming",
		"Programming",
		"Music & SFX",
		"Art"
	];
	
	public var soundTransition : FlxSound;
	
	override public function create():Void
	{
		super.create();
		
		trace('menu');
		
		var titleSprite = new FlxSprite();
		titleSprite.loadGraphic(AssetPaths.home__png);
		titleSprite.screenCenter(FlxAxes.XY);
		
		add(titleSprite);
		
		var pressToPlay = new FlxText();
		pressToPlay.text = "Press space to play!";
		pressToPlay.screenCenter(FlxAxes.XY);
		pressToPlay.y += 50;
		add(pressToPlay);
		
		FlxTween.tween(pressToPlay, {alpha: 0}, 0.7, {type: FlxTween.PINGPONG, ease: FlxEase.smoothStepInOut});
		
		var creditText = new FlxText(5, 10);
		creditText.text = "Made in 72h during the 41th Ludum Dare";
		add(creditText);
		//FlxG.camera.zoom = 2;
		
		for (i in 0...names.length) {
			var nameText = new FlxText();
			nameText.text = names[i];
			nameText.x = 5;
			nameText.y = 230 + 10 * i;
			add(nameText);
			
			var jobText = new FlxText();
			jobText.text = jobs[i];
			jobText.x = 120;
			jobText.y = 230 + 10 * i;
			add(jobText);
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
