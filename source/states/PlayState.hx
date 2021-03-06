package states;


import assetpaths.MusicAssetsPath;
import assetpaths.SoundAssetsPaths.SoundAssetsPath;
import flixel.FlxCamera;
import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import openfl.Assets;
import typedefs.Goto;

class PlayState extends FlxState {
	
	private var levelDataName			: String;
	private var anchor					: String;
	
	private var level					: CdbLevel;
	private var inventory				: PlayerInventory;
	private var cookbook				: CookBook;
	private var customerCardList		: CustomerCardList;
	private var loadedCookbook			: CookBook;
	private var cookbookToLoad			: Bool = false;
	private var recipePicker			: RecipePicker;
	private var validateRecipe          : Map<CdbData.IngredientsKind,Int> = new Map<CdbData.IngredientsKind,Int>();
	
	
	private var cameraUI				: FlxCamera;
	private var cameraHUD				: FlxCamera;
	private var cameraCookBook			: FlxCamera;
	private var cameraRecipePicker		: FlxCamera;
	
	private var cookbookOpen 			: Bool = false;
	private var recipePickerOpen 		: Bool = false;
	private var recipePickerHere 		: Bool = false;
	public  var initialInventoryLoad	: Bool = false;
	
	
	//narrative boolean
	
	
	
	private var _soundFadeIn						: FlxSound;
	private var _soundFadeOut						: FlxSound;
	private var soundNewCustomer					: FlxSound;
	//private var soundDrop						: FlxSound;
	//private var soundPickup						: FlxSound;
	
	private var explicationText : FlxText;
	
	private var soundCustomerHappy : Array<FlxSound> = new Array<FlxSound>();
	
	private var _totalElapsedTimeText			: FlxText;

	private var _totalCustomer				:Int=0;
	
	
	public function new(levelDataName:String, ?anchor:String, recipePick: Bool = false, initInvent : Bool = false) {
		super();
		this.levelDataName = levelDataName;
		this.anchor = anchor;
		recipePickerHere = recipePick;
		initialInventoryLoad = initInvent;
	}
	
	override public function create():Void
	{
		super.create();
		
		if (levelDataName == null) {
			levelDataName = "Kitchen_32";
		}
		
		CdbData.load(Assets.getText(AssetPaths.data__cdb));
		
		level = new CdbLevel(levelDataName, anchor);
		
		//////////////////////////////////////// Add all the layers in the right order
		// First "simple" ground tiles
		add(level.tilemapGround);
		
		// Then borders (autotiling)
		add(level.tilemapsGroundBorders);	
		
		// Then "ground objects" (alway under the rest)
		add(level.groundObjectsGroup);
		
		// ugly shadows
		add(level.npcShadowsSprites);
		
		add(level.npcFireBall);
		
		//////// Then "sortable" items (player, npcs, pickups, etc) so we can manipulate the draw order
		// objects (mostly non interactive doodads like trees, rocks, etc)
		add(level.sortableGroup);
		////////
		
		// Then "over objects" (alway above the rest)
		add(level.overObjectsGroup);
		
		// Then the over layer (top of trees and cliffs ?)
		add(level.tilemapOver);
		
		// Then, trigger zones
		add(level.changeScreenTriggers);
		add(level.commandTriggers);
		
		// Adding the collisions group
		add(level.collisionsGroup);
		
		add(level.player.weapons.peeler);

		add(level.player.weapons.knife);
		
		//Player health
		var playerH = new PlayerHUD(level.player);
		playerH.scrollFactor.set(0, 0);
		add(playerH);
		
		playerH.cameras = [this.camera];
		
		////Inventory
		if (!initialInventoryLoad)
		{
			inventory = new PlayerInventory();
			add(inventory);
			
			trace("LOAD INVENTORY");
			inventory.loadInventory();
		}
		else
		{
			inventory = new PlayerInventory(true);
			add(inventory);
		}
		
		initialInventoryLoad = false;
		
		cameraUI = new FlxCamera(0, 0, 300, Std.int(inventory._spriteSize * inventory._computedScale), 1);
		FlxG.cameras.add(cameraUI);
		inventory.cameras = [cameraUI];
		
		

		cookbook = new CookBook(inventory);
		add(cookbook);
		
		cameraCookBook = new FlxCamera(FlxG.width - 10, Std.int(FlxG.height/2), 96, 128, 1);
		FlxG.cameras.add(cameraCookBook);
		cookbook.cameras = [cameraCookBook];
		
		customerCardList = new CustomerCardList(cookbook);
		//customerCardList.scrollFactor.set(0, 0);
		add(customerCardList);
		
		//cameraHUD = new FlxCamera(0, Std.int(inventory._spriteSize * inventory._computedScale) + 10 , 32, 32 * 5);
		cameraHUD = new FlxCamera(0, Std.int(inventory._spriteSize * inventory._computedScale)+ 20 , 32, 32 * 5);
		//cameraHUD = new FlxCamera(0, 1000) + 10 , 32, 32 * 5);
		FlxG.cameras.add(cameraHUD);
		customerCardList.cameras = [cameraHUD];
		
		_totalElapsedTimeText = new FlxText(0, 25, 100);
		_totalElapsedTimeText.screenCenter(FlxAxes.X);
		_totalElapsedTimeText.text = FlxStringUtil.formatTime(0, true);
		_totalElapsedTimeText.autoSize = false;
		_totalElapsedTimeText.alignment = FlxTextAlign.CENTER;
		_totalElapsedTimeText.borderStyle = FlxTextBorderStyle.SHADOW;
		_totalElapsedTimeText.borderSize = 3;
		//_totalElapsedTimeText.cameras = [cameraHUD];
		_totalElapsedTimeText.scrollFactor.set(0, 0);
		trace(_totalElapsedTimeText);
		add(_totalElapsedTimeText);
		
		
		
		//RecipeBook camera
		if (Storage.recipe1name != null)
		{
			trace("LOAD RECIPE 1");
			trace("NAME :" + Storage.recipe1name);
			cookbook.loadRecipe1(Storage.recipe1);
			
			if (Storage.recipe2name != null)
			{
				trace("LOAD RECIPE 2");
				cookbook.loadRecipe2(Storage.recipe2);
				
				if (Storage.recipe3name != null)
				{
					trace("LOAD RECIPE 3");
					cookbook.loadRecipe3(Storage.recipe3);
				}	
			}
		}
		
		//Picker
		// Horrible facon de regarder si on doit créer les recettes
		if (Storage.recipe3.length == 0)
		{
			recipePicker = new RecipePicker(inventory,cookbook);
			add(recipePicker);
			
			cameraRecipePicker = new FlxCamera(10, 40, 192, 256, 1);
			cameraRecipePicker.visible = false;
			//cameraRecipePicker.setPosition(cameraRecipePicker.x - recipePicker._backgroundSprite.width, cameraRecipePicker.y);
			//cameraRecipePicker.setPosition(cameraRecipePicker.x + recipePicker._backgroundSprite.width + 10 , cameraRecipePicker.y);
			FlxG.cameras.add(cameraRecipePicker);
			recipePicker.cameras = [cameraRecipePicker];
			
			explicationText = new FlxText(0);
			explicationText.size = 12;
			explicationText.text = "Create today's menu [O]";
			explicationText.screenCenter();
			explicationText.y -= 50;
			explicationText.scrollFactor.set(0, 0);
			explicationText.borderStyle = FlxTextBorderStyle.OUTLINE;
			explicationText.cameras = [FlxG.camera];
			add(explicationText);
			
			//if (recipePicker._recipesAreFull) {
				//
			//}
		}
		
		
		// Camera setup
		FlxG.camera.follow(level.player, FlxCameraFollowStyle.LOCKON, 0.5);
		FlxG.camera.snapToTarget();
		
		level.tilemapGround.follow(FlxG.camera, 0, true);
		
		FlxG.camera.fade(FlxColor.BLACK, 0.2, true);
		
		if (levelDataName == "Kitchen_32") {
			// TODO: condition en fonction de la vie du player ?
			if (true) {
				FlxG.sound.playMusic(MusicAssetsPath.Kitchen__ogg);
			} else {
				FlxG.sound.playMusic(MusicAssetsPath.Kitchenfast__ogg);
			}
		} else {
			FlxG.sound.playMusic(MusicAssetsPath.Darkjungle__ogg);
		}
		FlxG.sound.music.fadeIn(1, 0, 0.7);
		
		_soundFadeIn = FlxG.sound.load(SoundAssetsPath.fadein__ogg, 0.25);
		_soundFadeOut = FlxG.sound.load(SoundAssetsPath.fadeout__ogg, 0.25);
		soundNewCustomer = FlxG.sound.load(SoundAssetsPath.client_new_2__ogg, 0.7);
		//soundDrop = FlxG.sound.load(SoundAssetsPath.ingredient_drop__ogg, 0.7);
		//soundPickup = FlxG.sound.load(SoundAssetsPath.ingredient_pickup__ogg, 0.7);
		
		soundCustomerHappy.push(FlxG.sound.load(SoundAssetsPath.client_success_1__ogg, 0.7));
		soundCustomerHappy.push(FlxG.sound.load(SoundAssetsPath.client_success_2__ogg, 0.7));
		soundCustomerHappy.push(FlxG.sound.load(SoundAssetsPath.client_success_3__ogg, 0.7));
		soundCustomerHappy.push(FlxG.sound.load(SoundAssetsPath.client_success_4__ogg, 0.7));
		
		_soundFadeIn.play();
	}
	
	override public function update(elapsed:Float):Void {
		// Mandatory
		super.update(elapsed);
		
		if (FlxMath.roundDecimal(Storage.timer, 0) == 15 && Storage.nbCustomer == 0)
		{
			var customer = new Customer(0, 0, Storage.nbCustomer, cookbook, customerCardList);
			Storage.nbCustomer++;
			soundNewCustomer.play(true);
		}
		
		if (FlxMath.roundDecimal(Storage.timer, 0) == 25 && Storage.nbCustomer == 1)
		{
			var customer = new Customer(0, 0, Storage.nbCustomer, cookbook, customerCardList);
			Storage.nbCustomer++;
			soundNewCustomer.play(true);
		}
		
		if (FlxMath.roundDecimal(Storage.timer, 0) == 45 && Storage.nbCustomer == 2)
		{
			var customer = new Customer(0, 0, Storage.nbCustomer, cookbook, customerCardList);
			Storage.nbCustomer++;
			soundNewCustomer.play(true);
		}
		
		if (FlxMath.roundDecimal(Storage.timer, 0) == 50 && Storage.nbCustomer == 3)
		{
			var customer = new Customer(0, 0, Storage.nbCustomer, cookbook, customerCardList);
			Storage.nbCustomer++;
			soundNewCustomer.play(true);
		}
		
		if (FlxMath.roundDecimal(Storage.timer, 0) == 55 && Storage.nbCustomer == 4)
		{
			var customer = new Customer(0, 0, Storage.nbCustomer, cookbook, customerCardList);
			Storage.nbCustomer++;
			soundNewCustomer.play(true);
		}
		
		if (FlxMath.roundDecimal(Storage.timer, 0) == 100 && Storage.nbCustomer == 5)
		{
			var customer = new Customer(0, 0, Storage.nbCustomer, cookbook, customerCardList);
			Storage.nbCustomer++;
			soundNewCustomer.play(true);
		}
		
		if (FlxMath.roundDecimal(Storage.timer, 0) == 120 && Storage.nbCustomer == 6)
		{
			var customer = new Customer(0, 0, Storage.nbCustomer, cookbook, customerCardList);
			Storage.nbCustomer++;
			soundNewCustomer.play(true);
		}
		
		if (FlxMath.roundDecimal(Storage.timer, 0) == 120  && Storage.nbCustomer == 7)
		{
			var customer = new Customer(0, 0, Storage.nbCustomer, cookbook, customerCardList);
			Storage.nbCustomer++;
			soundNewCustomer.play(true);
		}
		
		if (FlxMath.roundDecimal(Storage.timer, 0) == 160 && Storage.nbCustomer == 8)
		{
			var customer = new Customer(0, 0, Storage.nbCustomer, cookbook, customerCardList);
			Storage.nbCustomer++;
			soundNewCustomer.play(true);
		}
		
		if (FlxMath.roundDecimal(Storage.timer, 0) == 190 && Storage.nbCustomer == 9)
		{
			var customer = new Customer(0, 0, Storage.nbCustomer, cookbook, customerCardList);
			Storage.nbCustomer++;
			soundNewCustomer.play(true);
		}
		
		
		// Sort objects by their y value
		level.sortableGroup.sort(sortByY, FlxSort.DESCENDING);
		
		// Collisions handling
		FlxG.overlap(level.player, level.pickupSprites, PlayerPickup);
		FlxG.overlap(level.player, level.npcSprites, PlayerTakeDammages);
		FlxG.overlap(level.player, level.npcFireBall, PlayerTakeDammagesFireBall);
		
		FlxG.collide(level.player, level.collisionsGroup);
		FlxG.collide(level.player, level.objectsGroup);
		FlxG.collide(level.player, level.groundObjectsGroup);
		FlxG.collide(level.player, level.overObjectsGroup);
		
		FlxG.collide(level.npcSprites, level.collisionsGroup);
		FlxG.collide(level.npcSprites, level.objectsGroup);
		FlxG.collide(level.npcSprites, level.groundObjectsGroup);
		FlxG.collide(level.npcSprites, level.overObjectsGroup);
		FlxG.collide(level.npcSprites, level.npcSprites);
		
		FlxG.overlap(level.player.weapons.peeler, level.npcSprites, OnEnemyHurtCallback);
		FlxG.overlap(level.player.weapons.knife, level.npcSprites, OnEnemyHurtCallback);
		
		FlxG.overlap(level.player, level.commandTriggers, OnTriggerCommandCallback);
		
		// pas propre pour éviter que les npcs s'enfuient
		FlxG.collide(level.npcSprites, level.changeScreenTriggers);
		
		// pas propre, pour empêcher le player de s'enfuir de la cuisine tant que y'a pas 3 recettes dans le bouquin
		if (levelDataName == "Kitchen_32" && Storage.recipe3.length == 0) {
			FlxG.collide(level.player, level.changeScreenTriggers);
		} else {
			FlxG.overlap(level.player, level.changeScreenTriggers, ChangeScreenTriggerCallback);
		}
		
		level.npcSprites.forEachAlive(checkEnemyVision);
		
		//RECIPE BOOK
		if (FlxG.keys.pressed.P)
		{
			if (!cookbookOpen)
			{
				cookbookOpen = true;
				cameraCookBook.setPosition(cameraCookBook.x - cookbook._backgroundSprite.width, cameraCookBook.y);
				FlxG.sound.play(SoundAssetsPath.cookbook_open_close__ogg);
			}
		}
		
		if (FlxG.keys.justReleased.P)
		{
			
			if (!recipePickerOpen)
			{
				cookbookOpen = false;
				cameraCookBook.setPosition(cameraCookBook.x + cookbook._backgroundSprite.width, cameraCookBook.y);
				FlxG.sound.play(SoundAssetsPath.cookbook_open_close__ogg);
			}
		}
		
		if (Storage.recipe3.length == 0)
		{
			if (FlxG.keys.justPressed.O)
			{
				FlxG.sound.play(SoundAssetsPath.cookbook_open_close__ogg);
				activeRecipePicker();		
			}
		}
		
		
		// Timer du scord
		if (StringTools.startsWith(levelDataName, "Cellar") || Storage.recipe3.length != 0) {
			Storage.timer += elapsed;
			_totalElapsedTimeText.text = FlxStringUtil.formatTime(Storage.timer, true);
		}
		
		if (FlxG.keys.justPressed.NUMPADNINE)
		{
			var customer = new Customer(0, 0, Storage.nbCustomer, cookbook, customerCardList);
			Storage.nbCustomer++;
			soundNewCustomer.play(true);
		}
		
		if (FlxG.keys.justPressed.NUMPADSEVEN)
		{
			customerCardList.removeCardByIdRecipe(2);
			
		}
		
		if (recipePickerOpen && FlxG.keys.justPressed.UP)
		{
			recipePicker.changeCursorPos(-1);
		}
		
		if (recipePickerOpen && FlxG.keys.justPressed.DOWN)
		{
			recipePicker.changeCursorPos(1);
		}
		
		if ( recipePickerOpen && FlxG.keys.justPressed.SPACE && !recipePicker._recipesAreFull)
		{
			recipePicker.selectIngredient();
		}
		
		if ( recipePickerOpen && FlxG.keys.justPressed.SPACE && recipePicker._recipesAreFull)
		{
			activeRecipePicker();	
		}
		
		if ( recipePickerOpen && FlxG.keys.justPressed.ENTER)
		{
			recipePicker.validRecipe();
		}
		
		//trace(levelDataName);
		if (levelDataName == "Kitchen_32" && (FlxG.keys.justPressed.NUMPADONE || FlxG.keys.justPressed.F))
		{
			
			
			if (Storage.recipe1name != null)
			{
				var validIngredient  = 0;
				validateRecipe = new Map<CdbData.IngredientsKind,Int>();
				for (ingredient in Storage.recipe1)
				{
					var value = 0;
					if (validateRecipe.get(ingredient) != null)
					{
						value = validateRecipe.get(ingredient);
					}
					value++;
					validateRecipe.set(ingredient, value);
				}
				
				trace("RECETTE 1 :" +validateRecipe.toString());
				
				
				for (key in validateRecipe.keys())
				{
					if (Storage.ingredientsCount.get(key) >= validateRecipe.get(key))
					{
						validIngredient += validateRecipe.get(key);
					}
				}
				
				trace("VALID INGRE : " + validIngredient);
				
				if(validIngredient == Storage.recipe1.length)
				{
					
					
					if (customerCardList.removeCardByIdRecipe(1))
					{
						for (key in validateRecipe.keys())
						{
							Storage.ingredientsCount.set(key,Storage.ingredientsCount.get(key) - validateRecipe.get(key));
						}
						
						inventory.loadInventory();
						soundCustomerHappy[FlxG.random.int(0, soundCustomerHappy.length - 1)].play();
					}
					
				}
			}
			
		}
		
		if (levelDataName == "Kitchen_32" && (FlxG.keys.justPressed.NUMPADTWO || FlxG.keys.justPressed.G))
		{
			
			
			if (Storage.recipe2name != null)
			{
				var validIngredient  = 0;
				validateRecipe = new Map<CdbData.IngredientsKind,Int>();
				
				for (ingredient in Storage.recipe2)
				{
					var value = 0;
					if (validateRecipe.get(ingredient) != null)
					{
						value = validateRecipe.get(ingredient);
					}
					value++;
					validateRecipe.set(ingredient, value);
				}
				
				trace("RECETTE 2 :" +validateRecipe.toString());
				
				
				for (key in validateRecipe.keys())
				{
					if (Storage.ingredientsCount.get(key) >= validateRecipe.get(key))
					{
						validIngredient += validateRecipe.get(key);
						
					}
					
				}
				trace("VALID INGRE : " + validIngredient);
				
				if(validIngredient == Storage.recipe2.length)
				{
					
					
					if (customerCardList.removeCardByIdRecipe(2))
					{
						for (key in validateRecipe.keys())
						{
							Storage.ingredientsCount.set(key,Storage.ingredientsCount.get(key) - validateRecipe.get(key));
						}
						
						inventory.loadInventory();
						soundCustomerHappy[FlxG.random.int(0, soundCustomerHappy.length - 1)].play();
					}
					
				}
			}
			
		}
		
		if (levelDataName == "Kitchen_32" && (FlxG.keys.justPressed.NUMPADTHREE || FlxG.keys.justPressed.H))
		{
			
			
			if (Storage.recipe3name != null)
			{
				var validIngredient  = 0;
				validateRecipe = new Map<CdbData.IngredientsKind,Int>();
				
				for (ingredient in Storage.recipe3)
				{
					var value = 0;
					if (validateRecipe.get(ingredient) != null)
					{
						value = validateRecipe.get(ingredient);
					}
					value++;
					validateRecipe.set(ingredient, value);
				}
				
				trace("RECETTE 3 :" + validateRecipe.toString());
				
				
				for (key in validateRecipe.keys())
				{
					if (Storage.ingredientsCount.get(key) >= validateRecipe.get(key))
					{
						validIngredient += validateRecipe.get(key);
					}
				}
				trace("QUANTITE DEMANDE : " + Storage.recipe3.length);
				trace("VALID INGRE : " + validIngredient);
				
				if(validIngredient == Storage.recipe3.length)
				{
					
					
					if (customerCardList.removeCardByIdRecipe(3))
					{
						for (key in validateRecipe.keys())
						{
							Storage.ingredientsCount.set(key,Storage.ingredientsCount.get(key) - validateRecipe.get(key));
						}
						
						inventory.loadInventory();
						soundCustomerHappy[FlxG.random.int(0, soundCustomerHappy.length - 1)].play();
					}
					
				}
			}
		}
		
		//if (FlxG.keys.justPressed.A)
		//{
			//var cust = new Customer(0, 0, 0, cookbook, customerCardList);
		//}
		
		if (FlxG.keys.justPressed.M) {
			FlxG.sound.toggleMuted();
		}
		
		if (explicationText != null) {
			if (recipePicker._recipesAreFull) {
				explicationText.fieldWidth = 225;
				explicationText.text = "Go down to your cellar to find ingredients\n\n Press [P] to open your Cookédex";
				explicationText.alignment = FlxTextAlign.CENTER;
				explicationText.autoSize = false;
				explicationText.screenCenter();
				explicationText.y -= 50;
			}
			if (recipePickerOpen) {
				explicationText.visible = false;
			} else {
				explicationText.visible = true;
			}
		}
		
		// Debug
		#if debug
		if(FlxG.keys.pressed.SHIFT) {
			FlxG.camera.zoom += FlxG.mouse.wheel / 20.;
			
			if (FlxG.keys.justPressed.ONE) {
				if (FlxG.keys.pressed.SHIFT) {
					level.tilemapsGroundBorders.visible = !level.tilemapsGroundBorders.visible;
				} else {
					level.tilemapGround.visible = !level.tilemapGround.visible;
				}
			}
			
			if (FlxG.keys.justPressed.TWO) {
				level.tilemapObjects.visible = !level.tilemapObjects.visible;
			}
			if (FlxG.keys.justPressed.THREE) {
				level.tilemapOver.visible = !level.tilemapOver.visible;
			}
			if (FlxG.keys.justPressed.K) {
				if (level.npcSprites.length > 0) {
					var randomEnemy = level.npcSprites.getRandom(0, 0);
					OnEnemyHurtCallback(level.player, randomEnemy);
				}
			}
			if (FlxG.keys.justPressed.R && FlxG.keys.pressed.CONTROL) {
				Storage.reset();
				FlxG.resetGame();
			} else if (FlxG.keys.justPressed.R) {
				FlxG.switchState(new PlayState(levelDataName));
			}
		}
		
		if (FlxG.keys.pressed.CONTROL) {
			if (FlxG.keys.justPressed.NUMPADPERIOD) {
				FlxG.switchState(new PlayState("Cellar_32_0"));
			} else if (FlxG.keys.justPressed.NUMPADZERO) {
				FlxG.switchState(new PlayState("Kitchen_32"));
			} else if (FlxG.keys.justPressed.NUMPADONE) {
				FlxG.switchState(new PlayState("Cellar_32_1"));
			} else if (FlxG.keys.justPressed.NUMPADTWO) {
				FlxG.switchState(new PlayState("Cellar_32_2"));
			} else if (FlxG.keys.justPressed.NUMPADTHREE) {
				FlxG.switchState(new PlayState("Cellar_32_3"));
			} else if (FlxG.keys.justPressed.NUMPADFOUR) {
				FlxG.switchState(new PlayState("Cellar_32_4"));
			} else if (FlxG.keys.justPressed.NUMPADFIVE) {
				FlxG.switchState(new PlayState("Cellar_32_5"));
			}
		}
		#end
	}
	
	private function activeRecipePicker()
	{
			cameraRecipePicker.visible = !cameraRecipePicker.visible;
			recipePickerOpen = !recipePickerOpen;
			
			if (cameraRecipePicker.visible) 
			{
				level.player.disableAim();
			}
			else
			{
				level.player.enableAim();
			}
			
			cookbookOpen = !cookbookOpen;
			if (cookbookOpen)
			{
				cameraCookBook.setPosition(cameraCookBook.x - cookbook._backgroundSprite.width, cameraCookBook.y);
			}
			else
			{
				cameraCookBook.setPosition(cameraCookBook.x + cookbook._backgroundSprite.width, cameraCookBook.y);
			}
	}
	
	private function ChangeScreenTriggerCallback(player:Player, triggerSprite:FlxSprite) {
		var goto:Goto = level.mapOfGoto.get(triggerSprite);
		
		_soundFadeOut.play();
		FlxG.sound.music.fadeOut(0.2, 0);
		FlxG.camera.fade(FlxColor.BLACK, 0.2, false, function() {
			if (goto.l == "Kitchen_32") {
				FlxG.switchState(new PlayState(goto.l, goto.anchor,true));
			} else {
				//var levelName = goto.l + "_0";
				var levelName = goto.l + "_" + Std.string(FlxG.random.int(1, 3));
				trace(levelName);
				FlxG.switchState(new PlayState(levelName, goto.anchor,false));
			}
		});
	}
	
	private function OnTriggerCommandCallback(player:Player, triggerSprite:FlxSprite) {
		var commandNumber = level.mapOfCommands.get(triggerSprite);
		
		// TODO: commandNumber est l'id de [0 à 5] de la zone triggered
		//trace(commandNumber);
		
	}
	
	private function PlayerPickup(player:Player, ingredient:IngredientPickup):Void
	{
		if (player.alive && player.exists && ingredient.alive && ingredient.exists)
		{
			FlxG.sound.play(SoundAssetsPath.ingredient_pickup__ogg, 0.7);
			ingredient.allowCollisions = FlxObject.NONE;
			inventory.updateValueAdd(ingredient.ingredientType, 1);
			ingredient.kill();
		}
	}
	
	private function PlayerTakeDammages(player:Player, enemy:IngredientEnemy):Void
	{
		if (player.takeDamage(enemy.damage, enemy.getGraphicMidpoint()))
		{
			//var tweenEnemy = FlxTween.tween(player, {alpha: 0}, 0.1 , {type: FlxTween.PINGPONG, ease: FlxEase.linear});
			//new FlxTimer().start(0.4, function(timer:FlxTimer):Void 
			//{
				//tweenEnemy.cancel();
				//player.alpha = 1;
			//});
		}
		else
		{
			Storage.player1Stats.reset();
			
			//_soundFadeOut.play();
			FlxG.sound.music.fadeOut(0.2, 0);
			FlxG.camera.fade(FlxColor.BLACK, 0.2, false, function() {
				FlxG.switchState(new GameOverState());
			});
			
		}
	}
	
	private function PlayerTakeDammagesFireBall(player:Player, enemy:FireBall):Void
	{
		if (player.takeDamage(enemy.damage, enemy.getGraphicMidpoint()))
		{
			//var tweenEnemy = FlxTween.tween(player, {alpha: 0}, 0.1 , {type: FlxTween.PINGPONG, ease: FlxEase.linear});
			//new FlxTimer().start(0.4, function(timer:FlxTimer):Void 
			//{
				//tweenEnemy.cancel();
				//player.alpha = 1;
			//});
		}
		else
		{
			Storage.player1Stats.reset();
			
			//_soundFadeOut.play();
			FlxG.sound.music.fadeOut(0.2, 0);
			FlxG.camera.fade(FlxColor.BLACK, 0.2, false, function() {
				FlxG.switchState(new GameOverState());
			});
			
		}
	}
	
	private var enemiesHurtTweenMap: Map<IngredientEnemy, FlxTween> = new Map<IngredientEnemy, FlxTween>();
	
	private function OnEnemyHurtCallback(sprite: FlxSprite, enemy: IngredientEnemy) 
	{
		if (enemy.takeDamage(level.player.getCurrentWeaponDmg(), level.player.getGraphicMidpoint()))
		{
				
		}
		
		if (enemiesHurtTweenMap.get(enemy) == null || !enemiesHurtTweenMap.get(enemy).active) {
			
			
			
			//Blinking
			var tweenEnemy = FlxTween.tween(enemy, {alpha: 0}, 0.05, {type: FlxTween.PINGPONG, ease: FlxEase.linear});
			enemiesHurtTweenMap.set(enemy, tweenEnemy);
			new FlxTimer().start(0.4, function(timer:FlxTimer):Void {
				tweenEnemy.cancel();
				if (enemy != null) {
					enemy.alpha = 1;
				}
			});
			/////////////
			
			
		}
		
		if (enemy.hp <= 0) {
			OnEnemyDiesCallBack(enemy);
		}
	}
	
	private function OnEnemyDiesCallBack(enemy: IngredientEnemy) {
		for (drop in enemy.getDrops()) {
			add(drop);
			
			//var shadowSprite = new ShadowSprite(drop);
			//shadowSprite.scale.set(0.5, 0.5);
			//shadowSprite.y -= 16;
			//add(shadowSprite);
			
			drop.scale.set(0.01, 0.01);
			FlxTween.tween(drop.scale, {x: 1, y: 1}, 0.3, {ease:FlxEase.elasticInOut});
			var x = drop.x;
			var y = drop.y;
			FlxTween.tween(drop, {x: x + FlxG.random.float(-32, 32), y: y + FlxG.random.float(-32, 32)}, 0.3, {ease:FlxEase.elasticInOut, onComplete: function(_) {
				level.pickupSprites.add(drop);
			}});
			//FlxG.sound.play(SoundAssetsPath.ingredient_drop__ogg, 0.7);
		}
		enemy.kill();
		FlxG.sound.play(SoundAssetsPath.enemy_death__ogg, 0.4);
		level.npcSprites.remove(enemy, true);
	}
	
	private function checkEnemyVision(e:IngredientEnemy):Void
	{
		var playerPos = level.player.getMidpoint();
		if (level.tilemapObjects.ray(e.getMidpoint(), playerPos))
		{
			if (playerPos.distanceTo(e.getPosition()) > e.currentDetectionRadius)
			{
				e.seesPlayer = false;
			}
			else
			{
				e.seesPlayer = true;
				e.playerPos.copyFrom(playerPos);
			}
		}
		else
			e.seesPlayer = false;
	}
	
	
	private function story():Void
	{
		var intro = "HELLO YOU ARE THE NEW COOK OF HUNTER DINER THIS DINNER IS A LITTLE BIT SPECIAL CUZ U HAVE TO GET THE ELEMENT IN THE CELLAR ! BEFORE DOING THIS YOU HAVE TO CHOOSE YOU RECIPE (A RECIPE MUST CONTAINS BETWEEN 2 AND 5 INGREDIENTS)";
		
		var introText = new FlxText(0, 0, 0, intro, 12);
		
		
		
	}
	
	/**
	* Comparateur perso pour trier les sprites par Y croissant (en tenant compte de leur hauteur)
	* @param	Order
	* @param	Obj1
	* @param	Obj2
	* @return
	*/
	public static function sortByY(Order:Int, Obj1:FlxObject, Obj2:FlxObject):Int {
		return Obj1.y + Obj1.height < Obj2.y + Obj2.height ? -Order : Order;
	}
}