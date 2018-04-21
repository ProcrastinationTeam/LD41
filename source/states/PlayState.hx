package states;


import flixel.FlxCamera;
import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import openfl.Assets;
import typedefs.Goto;

class PlayState extends FlxState {
	
	private var levelDataName			: String;
	private var anchor					: String;
	
	private var level					: CdbLevel;
	private var inventory				: PlayerInventory;
	private var cookbook				: CookBook;
	private var recipePicker			: RecipePicker;
	
	private var cameraUI				: FlxCamera;
	private var cameraCookBook			: FlxCamera;
	private var cameraRecipePicker		: FlxCamera;
	
	private var cookbookOpen 			: Bool = false;
	private var recipePickerOpen 		: Bool = false;
	
	
	public function new(levelDataName:String, ?anchor:String) {
		super();
		this.levelDataName = levelDataName;
		this.anchor = anchor;
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
		
		add(level.player.peeler);
		
		////Inventory
		inventory = new PlayerInventory();
		add(inventory);
		
		cameraUI = new FlxCamera(0, 0, 300, Std.int(inventory._spriteSize * inventory._computedScale), 1);
		FlxG.cameras.add(cameraUI);
		inventory.cameras = [cameraUI];
		
		//RecipeBook camera
		cookbook = new CookBook(inventory);
		add(cookbook);
		
		cameraCookBook = new FlxCamera(FlxG.width - 10, Std.int(FlxG.height/2), 96, 128, 1);
		FlxG.cameras.add(cameraCookBook);
		cookbook.cameras = [cameraCookBook];
		
		
		//Picker
		
		recipePicker = new RecipePicker(inventory);
		add(recipePicker);
		
		cameraRecipePicker = new FlxCamera(10, 40, 192, 256, 1);
		cameraRecipePicker.setPosition(cameraRecipePicker.x - recipePicker._backgroundSprite.width, cameraRecipePicker.y);
		FlxG.cameras.add(cameraRecipePicker);
		recipePicker.cameras = [cameraRecipePicker];
		
		
		
		// Camera setup
		FlxG.camera.follow(level.player, FlxCameraFollowStyle.LOCKON, 0.5);
		FlxG.camera.snapToTarget();
		
		level.tilemapGround.follow(FlxG.camera, 0, true);
		
		FlxG.camera.fade(FlxColor.BLACK, 0.2, true);
		
	}
	
	override public function update(elapsed:Float):Void {
		// Mandatory
		super.update(elapsed);
		
		// Sort objects by their y value
		level.sortableGroup.sort(sortByY, FlxSort.DESCENDING);
		
		// Collisions handling
		FlxG.collide(level.player, level.npcSprites);
		FlxG.collide(level.player, level.collisionsGroup);
		FlxG.collide(level.player, level.objectsGroup);
		FlxG.collide(level.player, level.groundObjectsGroup);
		FlxG.collide(level.player, level.overObjectsGroup);
		
		FlxG.overlap(level.player, level.changeScreenTriggers, ChangeScreenTriggerCallback);
		
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
			FlxG.switchState(new PlayState(goto.l, goto.anchor));
		});
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