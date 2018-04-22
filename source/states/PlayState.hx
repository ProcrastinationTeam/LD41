package states;


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
	private var loadedCookbook			: CookBook;
	private var cookbookToLoad			: Bool = false;
	private var recipePicker			: RecipePicker;
	
	private var cameraUI				: FlxCamera;
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
			cameraRecipePicker.setPosition(cameraRecipePicker.x - recipePicker._backgroundSprite.width, cameraRecipePicker.y);
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
		
		FlxG.collide(level.player, level.collisionsGroup);
		FlxG.collide(level.player, level.objectsGroup);
		FlxG.collide(level.player, level.groundObjectsGroup);
		FlxG.collide(level.player, level.overObjectsGroup);
		
		FlxG.overlap(level.player, level.changeScreenTriggers, ChangeScreenTriggerCallback);
		FlxG.overlap(level.player.weapons.peeler, level.npcSprites, OnEnemyHurtCallback);
		FlxG.overlap(level.player.weapons.knife, level.npcSprites, OnEnemyHurtCallback);
		
		//RECIPE BOOK
		if (FlxG.keys.justPressed.P)
		{
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
		
		if (recipePickerHere)
		{
			if (FlxG.keys.justPressed.O)
			{
				recipePickerOpen = !recipePickerOpen;
				if (recipePickerOpen)
				{
					cameraRecipePicker.setPosition(cameraRecipePicker.x + recipePicker._backgroundSprite.width, cameraRecipePicker.y);
				}
				else
				{
					cameraRecipePicker.setPosition(cameraRecipePicker.x - recipePicker._backgroundSprite.width, cameraRecipePicker.y);
				}
				
				//cookbook.startRecipePicker();
			}
		}
		
		if (recipePickerOpen && FlxG.keys.justPressed.UP)
		{
			recipePicker.changeCursorPos(-1);
		}
		
		if (recipePickerOpen && FlxG.keys.justPressed.DOWN)
		{
			recipePicker.changeCursorPos(1);
		}
		
		if ( recipePickerOpen && FlxG.keys.justPressed.SPACE)
		{
			recipePicker.selectIngredient();
		}
		
		if ( recipePickerOpen && FlxG.keys.justPressed.ENTER)
		{
			recipePicker.validRecipe();
		}
		
		
		
		// Debug
		#if debug
		if(FlxG.keys.pressed.SHIFT) {
			FlxG.camera.zoom += FlxG.mouse.wheel / 20.;
		}
		
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
		#end
		
		if (FlxG.keys.justPressed.R && FlxG.keys.pressed.SHIFT) {
			FlxG.resetGame();
		} else if (FlxG.keys.justPressed.R) {
			FlxG.resetState();
		}
	}
	
	private function ChangeScreenTriggerCallback(player:Player, triggerSprite:FlxSprite) {
		var goto:Goto = level.mapOfGoto.get(triggerSprite);
		
		FlxG.camera.fade(FlxColor.BLACK, 0.2, false, function() {
			if (goto.l == "Kitchen_32") {
				FlxG.switchState(new PlayState(goto.l, goto.anchor,true));
			} else {
				var levelName = goto.l + "_1";
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
			inventory.updateValueAdd(ingredient.ingredientType, 1);
			ingredient.kill();
		}
	}
	
	private var enemiesHurtTweenMap: Map<IngredientEnemy, FlxTween> = new Map<IngredientEnemy, FlxTween>();
	
	private function OnEnemyHurtCallback(sprite: FlxSprite, enemy: IngredientEnemy) {
		enemy.hp -= level.player.sliceDmg;
		
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