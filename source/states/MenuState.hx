package states;

import assetpaths.MusicAssetsPath;
import assetpaths.SoundAssetsPaths.SoundAssetsPath;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;

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
	
	public var lightSprite : FlxSprite;
	public var darkSprite : FlxSprite;
	public var overlaySprite : FlxSprite;
	
	public var music : FlxSound;
	
	public var soundBzz : FlxSound;
	public var timeSinceLastBzz : Float = 0;
	public var minTimeBetweenBzz : Float = 2;
	
	public var tween : FlxTween;
	
	override public function create():Void
	{
		super.create();
		
		music = FlxG.sound.load(MusicAssetsPath.credits__ogg, 1, true);
		music.play();
		
		lightSprite = new FlxSprite();
		lightSprite.loadGraphic(AssetPaths.home_light__png);
		lightSprite.screenCenter(FlxAxes.XY);
		lightSprite.alpha = 0;
		add(lightSprite);
		
		darkSprite = new FlxSprite();
		darkSprite.loadGraphic(AssetPaths.home_shadow__png);
		darkSprite.screenCenter(FlxAxes.XY);
		add(darkSprite);
		
		overlaySprite = new FlxSprite();
		overlaySprite.loadGraphic(AssetPaths.home_overlay__png);
		overlaySprite.screenCenter(FlxAxes.XY);
		add(overlaySprite);
		
		var creditText = new FlxText(5, 10);
		creditText.text = "Made in 72h during the 41th Ludum Dare";
		add(creditText);
		
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
		
		soundBzz = FlxG.sound.load(SoundAssetsPath.neon_bruitage__ogg, 1, false, null, false, false, null, EndBzz);
		
		Storage.ingredientsCount =  new Map<CdbData.IngredientsKind,Int>();
		Storage.recipe1 = new Array<CdbData.IngredientsKind>();
		Storage.recipe2 = new Array<CdbData.IngredientsKind>();
		Storage.recipe3 = new Array<CdbData.IngredientsKind>();
		
		Storage.recipe1name = null;
		Storage.recipe2name = null;
		Storage.recipe3name = null;
	}

	// TODO: zoom pour les credits
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		timeSinceLastBzz += elapsed;
		
		if (FlxG.mouse.justPressed || FlxG.keys.justPressed.SPACE) {
			music.fadeOut(0.3);
			
			FlxG.camera.fade(FlxColor.BLACK, 0.3, false, function() {
				FlxG.switchState(new PlayState("Kitchen_32", "Start", true, true));
			});
		}
		
		if (FlxG.keys.justPressed.R && FlxG.keys.pressed.SHIFT) {
			FlxG.resetGame();
		} else if (FlxG.keys.justPressed.R) {
			FlxG.resetState();
		}
		
		if (FlxG.mouse.getPosition().inCoords(160, 170, 40, 55)) {
			overlaySprite.alpha = 1;
		} else {
			overlaySprite.alpha = 0;
		}
		
		if (timeSinceLastBzz > minTimeBetweenBzz) {
			if (FlxG.random.bool(10)) {
				StartBzz();
			}
		}
		
		if (soundBzz.playing) {
			var rand = FlxG.random.float();
			lightSprite.alpha = rand;
			darkSprite.alpha = 1 - rand;
		}
	}
	
	public function StartBzz() {
		soundBzz.play();
		
		lightSprite.alpha = 1;
		darkSprite.alpha = 0;
		timeSinceLastBzz = 0;
		
		//tween = FlxTween.tween(darkSprite, {alpha: 0.5}, 0.05, {type: FlxTween.PINGPONG, ease: FlxEase.linear});
	}
	
	public function EndBzz() {
		//tween.cancel();
		
		lightSprite.alpha = 0;
		darkSprite.alpha = 1;
		timeSinceLastBzz = 0;
		trace("bnjour");
	}
}
