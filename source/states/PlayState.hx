package states;


import assetpaths.SoundAssetsPaths.SoundAssetsPath;
import flixel.FlxCamera;
import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
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
			levelDataName = "FirstVillage";
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
		
		// Adding the collisions group
		add(level.collisionsGroup);
		
		add(level.player.weapons.peeler);

		add(level.player.weapons.knife);
		
		
		//Player health
		var playerH = new PlayerHUD(level.player);
		playerH.scrollFactor.set(0, 0);
		add(playerH);
		
		
		
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
		
		//cameraHUD = new FlxCamera(0, Std.int(inventory._spriteSize * inventory._computedScale) + 10 , 32, 32 * 5);
		//FlxG.cameras.add(cameraHUD);
		//customerCardList.cameras = [cameraHUD];

		cookbook = new CookBook(inventory);
		add(cookbook);
		
		cameraCookBook = new FlxCamera(FlxG.width - 10, Std.int(FlxG.height/2), 96, 128, 1);
		FlxG.cameras.add(cameraCookBook);
		cookbook.cameras = [cameraCookBook];
		
		customerCardList = new CustomerCardList(cookbook);
		customerCardList.scrollFactor.set(0, 0);
		add(customerCardList);
		

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
		if (recipePickerHere)
		{
			recipePicker = new RecipePicker(inventory,cookbook);
			add(recipePicker);
			
			cameraRecipePicker = new FlxCamera(10, 40, 192, 256, 1);
			cameraRecipePicker.visible = false;
			//cameraRecipePicker.setPosition(cameraRecipePicker.x - recipePicker._backgroundSprite.width, cameraRecipePicker.y);
			//cameraRecipePicker.setPosition(cameraRecipePicker.x + recipePicker._backgroundSprite.width + 10 , cameraRecipePicker.y);
			FlxG.cameras.add(cameraRecipePicker);
			recipePicker.cameras = [cameraRecipePicker];
		}
		
		
		// Camera setup
		FlxG.camera.follow(level.player, FlxCameraFollowStyle.LOCKON, 0.5);
		FlxG.camera.snapToTarget();
		
		level.tilemapGround.follow(FlxG.camera, 0, true);
		
		FlxG.camera.fade(FlxColor.BLACK, 0.2, true);
		
		//FlxG.sound.playMusic(AssetPaths.Darkjungle__ogg, 0.5);
	}
	
	override public function update(elapsed:Float):Void {
		// Mandatory
		super.update(elapsed);
		
		// Sort objects by their y value
		level.sortableGroup.sort(sortByY, FlxSort.DESCENDING);
		
		// Collisions handling
		FlxG.overlap(level.player, level.pickupSprites, PlayerPickup);
		FlxG.overlap(level.player, level.npcSprites, PlayerTakeDammages);
		
		FlxG.collide(level.player, level.collisionsGroup);
		FlxG.collide(level.player, level.objectsGroup);
		FlxG.collide(level.player, level.groundObjectsGroup);
		FlxG.collide(level.player, level.overObjectsGroup);
		
		FlxG.collide(level.npcSprites, level.collisionsGroup);
		FlxG.collide(level.npcSprites, level.objectsGroup);
		FlxG.collide(level.npcSprites, level.groundObjectsGroup);
		FlxG.collide(level.npcSprites, level.overObjectsGroup);
		FlxG.collide(level.npcSprites, level.npcSprites);
		
		FlxG.overlap(level.player, level.changeScreenTriggers, ChangeScreenTriggerCallback);
		FlxG.overlap(level.player.weapons.peeler, level.npcSprites, OnEnemyHurtCallback);
		FlxG.overlap(level.player.weapons.knife, level.npcSprites, OnEnemyHurtCallback);
		
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
		
		if (recipePickerHere)
		{
			if (FlxG.keys.justPressed.O)
			{
				FlxG.sound.play(SoundAssetsPath.cookbook_open_close__ogg);
				activeRecipePicker();		
			}
		}
		
		if (recipePickerOpen && FlxG.keys.justPressed.Z)
		{
			recipePicker.changeCursorPos(-1);
		}
		
		if (recipePickerOpen && FlxG.keys.justPressed.S)
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
		if (levelDataName == "Kitchen_32" && FlxG.keys.justPressed.LEFT)
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
					for (key in validateRecipe.keys())
					{
						Storage.ingredientsCount.set(key,Storage.ingredientsCount.get(key) - validateRecipe.get(key));
					}
					
					inventory.loadInventory();
				}
			}
			
		}
		
		if (levelDataName == "Kitchen_32" && FlxG.keys.justPressed.DOWN)
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
					for (key in validateRecipe.keys())
					{
						Storage.ingredientsCount.set(key,Storage.ingredientsCount.get(key) - validateRecipe.get(key));
					}
					
					inventory.loadInventory();
				}
			}
			
		}
		
		if (levelDataName == "Kitchen_32" && FlxG.keys.justPressed.RIGHT)
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
				
				trace("VALID INGRE : " + validIngredient);
				
				if(validIngredient == Storage.recipe3.length)
				{
					for (key in validateRecipe.keys())
					{
						Storage.ingredientsCount.set(key,Storage.ingredientsCount.get(key) - validateRecipe.get(key));
					}
					
					inventory.loadInventory();
				}
			}
		}
		
		if (FlxG.keys.justPressed.A)
		{
			var cust = new Customer(0, 0, 0, cookbook, customerCardList);
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
			if (FlxG.keys.justPressed.R && FlxG.keys.pressed.SHIFT) {
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
				level.player.disableMovement();
			}
			else
			{
				level.player.enableMovement();
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
		
		FlxG.camera.fade(FlxColor.BLACK, 0.2, false, function() {
			if (goto.l == "Kitchen_32") {
				FlxG.switchState(new PlayState(goto.l, goto.anchor,true));
			} else {
				var levelName = goto.l + "_0";
				//var levelName = goto.l + "_" + Std.string(FlxG.random.int(1, 2));
				trace(levelName);
				FlxG.switchState(new PlayState(levelName, goto.anchor,false));
			}
		});
	}
	
	private function PlayerPickup(player:Player, ingredient:IngredientPickup):Void
	{
		if (player.alive && player.exists && ingredient.alive && ingredient.exists)
		{
			ingredient.allowCollisions = FlxObject.NONE;
			inventory.updateValueAdd(ingredient.ingredientType, 1);
			ingredient.kill();
		}
	}
	
	private function PlayerTakeDammages(player:Player, enemy:IngredientEnemy):Void
	{
		if (player.takeDamage(enemy.damage, enemy.x, enemy.y))
		{
			trace("HP : " + player.playerStats.currentHealth);
			//update Hp HUD
		}
		else
		{
			Storage.player1Stats.reset();
			FlxG.switchState(new GameOverState());
		}
	}
	
	private var enemiesHurtTweenMap: Map<IngredientEnemy, FlxTween> = new Map<IngredientEnemy, FlxTween>();
	
	private function OnEnemyHurtCallback(sprite: FlxSprite, enemy: IngredientEnemy) {
		enemy.hp -= level.player.getCurrentWeaponDmg();
		
		if (enemiesHurtTweenMap.get(enemy) == null || !enemiesHurtTweenMap.get(enemy).active) {
			var tweenEnemy = FlxTween.tween(enemy, {alpha: 0}, 0.05, {type: FlxTween.PINGPONG, ease: FlxEase.linear});
			enemiesHurtTweenMap.set(enemy, tweenEnemy);
			new FlxTimer().start(0.4, function(timer:FlxTimer):Void {
				tweenEnemy.cancel();
				if (enemy != null) {
					enemy.alpha = 1;
				}
			});
		}
		
		if (enemy.hp <= 0) {
			OnEnemyDiesCallBack(enemy);
		}
	}
	
	private function OnEnemyDiesCallBack(enemy: IngredientEnemy) {
		for (drop in enemy.getDrops()) {
			add(drop);
			level.pickupSprites.add(drop);
		}
		enemy.kill();
		level.npcSprites.remove(enemy, true);
	}
	
	private function checkEnemyVision(e:IngredientEnemy):Void
	{
		var playerPos = level.player.getMidpoint();
		if (level.tilemapObjects.ray(e.getMidpoint(), playerPos))
		{
			if (playerPos.distanceTo(e.getPosition()) > e.detectionRadius)
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