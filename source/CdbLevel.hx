package;

import cdb.Data.LayerMode;
import cdb.TileBuilder;
import cdb.Types.ArrayRead;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.tile.FlxTilemapExt;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import typedefs.Goto;
import typedefs.Set;
import CdbData;
import flixel.FlxG;

//var jdffdgdfg:cdb.CdbData.TilesetProps;

//var tileBuilder = new TileBuilder(tileSetProps, stride, total);
//var ground:Array<Int> = tileBuilder.buildGrounds(input, width);

//CdbData.decode(CdbData.levelDatas.all); // ?? cf issue

//[DB].[sheet].get([field]).[...]
//[DB].[sheet].resolve(["field"]).[...]
//[DB].[sheet].all[index].[...]

class CdbLevel {
	// "Entities"
	public var player 					: Player;
	public var playerShadow				: ShadowSprite;
	public var npcSprites 				: FlxTypedSpriteGroup<IngredientEnemy>				= new FlxTypedSpriteGroup<IngredientEnemy>();
	public var npcShadowsSprites 		: FlxTypedSpriteGroup<ShadowSprite>					= new FlxTypedSpriteGroup<ShadowSprite>();
	public var npcFireBall 				: FlxTypedSpriteGroup<FireBall>						= new FlxTypedSpriteGroup<FireBall>();
	public var pickupSprites 			: FlxTypedSpriteGroup<IngredientPickup>				= new FlxTypedSpriteGroup<IngredientPickup>();
	
	// Properties of the map (tile props and object props)
	public var mapOfObjects				: Map<Int, Set> 				= new Map<Int, Set>();
	public var mapOfProps				: Map<Int, Dynamic> 			= new Map<Int, Dynamic>();
	
	// Tilemaps
	// - One for the ground
	// - A group for ground borders (TODO: merge ?)
	// - One for the objects (mostly non interactive stuff (other than maybe collisions), like trees)
	// - One for over (??)
	public var tilemapGround			: FlxTilemap					= new FlxTilemap();
	public var tilemapsGroundBorders	: FlxTypedGroup<FlxTilemap>		= new FlxTypedGroup<FlxTilemap>();
	public var tilemapObjects 			: FlxTilemapExt					= new FlxTilemapExt();
	public var tilemapOver 				: FlxTilemap					= new FlxTilemap();
	
	public var groundObjectsGroup		: FlxSpriteGroup				= new FlxSpriteGroup();
	public var objectsGroup				: FlxSpriteGroup				= new FlxSpriteGroup();
	public var overObjectsGroup			: FlxSpriteGroup				= new FlxSpriteGroup();
	
	public var sortableGroup			: FlxSpriteGroup				= new FlxSpriteGroup();
	
	public var changeScreenTriggers		: FlxSpriteGroup				= new FlxSpriteGroup();
	public var commandTriggers			: FlxSpriteGroup					= new FlxSpriteGroup();
	
	public var mapOfGoto				: Map<FlxSprite, Goto> 			= new Map<FlxSprite, Goto>();
	public var mapOfCommands			: Map<FlxSprite, Int> 			= new Map<FlxSprite, Int>();
	public var mapOfAnchor				: Map<String, FlxPoint> 		= new Map<String, FlxPoint>();
	
	///////////////////////////////
	// From lowest to highest priority of collision (each successive one overrides the previous behaviour if there was one)
	// 1: Ground 	(water)
	// 2. Objects 	(trees, rocks, bridges, ladders, that kind of stuff)
	// 3. Collide	(full on funky layer with invisible walls, kill zones, mob only areas, etc)
	
	// Single array to handle multiple collisions per tile, example: bridge (object) above water (ground)
	public var arrayCollisions			: Array<Array<FlxObject>>;
	public var collisionsGroup			: FlxGroup						= new FlxGroup();
	
	// TODO: https://github.com/HaxeFlixel/flixel/issues/559 ?
	// private var tilemapCollisions		: FlxTilemap				= new FlxTilemap();
	///////////////////////////////
	
	// Depending on your map, this can impact the performances quite a lot
	// (With FlxTileMap as of March 2018, as far a I know)
	public static inline var ENABLE_MULTIPLE_GROUND_BORDER_TILEMAPS 	: Bool 	= true;
	public static inline var MAX_NUMBER_OF_GROUND_BORDER_TILEMAPS 		: Int 	= 20;
	
	// BORDEL
	public var levelDataName			: String;
	public var levelDataKind			: CdbData.LevelDatasKind;
	public var levelData 				: CdbData.LevelDatas;
	
	public var anchor					: String;
	
	public var tileSize = 32;
	private var stride = 15;
	
	public function new(levelDataName:String, ?anchor:String = "Start") {
		this.levelDataName = levelDataName;
		this.anchor = anchor;
		
		levelData = CdbData.levelDatas.resolve(levelDataName);
		
		//traces(levelData);
		
		// Default
		// trace(levelData.id);
		// trace(levelData.height);
		// trace(levelData.width);
		// trace(levelData.props);
		// trace(levelData.tileProps);
		// trace(levelData.layers);
		
		//trace(levelData.level);
		// Unique identifier (column is named "id" by default)
		
		//trace(levelData.height);
		// Height (in tiles)
		
		//trace(levelData.width);
		// Width (in tiles)
		
		//trace(levelData.props);
		// layers : Array<{ 
		// 		l (layer) : String, (layer's name)
		//		p (props) : { 
		//						?color : Int (integer representation ?), 
		// 						?alpha : Float (between 0 and 1), 
		//						?mode : String ("ground" or "objects", assumed tiles mode otherwise) }
		// 					}
		// }>,
		// tileSize : Int (size of the map tiles, one tile is [tileSize] pixels wide)
		
		//trace(levelData.tileProps);
		// TODO: 
		// Gibberish ? Each column is a new item in the list in the palette in the level editor (lots of "in the")
		// Each row ?
		
		// trace(levelData.layers);
		//traceLayers(levelData);
		
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// TODO: More generic
		//
		var forestTileset = levelData.props.getTileset(CdbData.levelDatas, "images/sprite_shit.png");
		
		computeMapOfProps(forestTileset);
		computeMapOfObjects(forestTileset);
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		// Process layers (ground and borders, objects, tiles)
		processLayers(levelData);
		
		// Process npcs (and player)
		processNpcs(levelData.npcs);
		
		// Process triggers
		processTriggerZones(levelData.triggers);
		
		// Process spawn points
		processNpcSpawnZones(levelData.npcSpawnPoints);
		
		// Process pickups
		processPickups(levelData.ingredients);
		
		// Place the player
		var newPosition = mapOfAnchor.get(anchor);
		player = new Player(newPosition.x * levelData.props.tileSize, newPosition.y * levelData.props.tileSize);
		playerShadow = new ShadowSprite(player, true);
		npcShadowsSprites.add(playerShadow);
		
		// pickups (custom layer)
		for (item in pickupSprites) {
			sortableGroup.add(item);
		}
		for (item in objectsGroup) {
			sortableGroup.add(item);
		}
		// npcs
		for (item in npcSprites) {
			sortableGroup.add(item);
		}
		// player
		sortableGroup.add(player);
		
		// TODO: move ? 
		for (y in 0...levelData.height) {
			for (x in 0...levelData.width) {
				if (arrayCollisions[y][x] != null) {
					collisionsGroup.add(arrayCollisions[y][x]);
				}
			}
		}
	}
	
	private function processPickups(pickups:ArrayRead < CdbData.LevelDatas_ingredients > ):Void {
		for (pickup in pickups) {
			// TODO: temp
			var pickupSprite = new IngredientPickup(pickup.x * tileSize, pickup.y * tileSize, pickup.kindId);
			pickupSprites.add(pickupSprite);
		}
	}
	
	private function processNpcs(npcs:ArrayRead < CdbData.LevelDatas_npcs > ):Void {
		for (npc in npcs) {
			spawnNpc(npc.x, npc.y, CdbData.npcs.get(npc.kindId));
		}
	}
	
	private function processNpcSpawnZones(spawnPoints:ArrayRead < CdbData.LevelDatas_npcSpawnPoints > ):Void {
		for (spawnPoint in spawnPoints) {
			for (mob in spawnPoint.mobs) {
				if (FlxG.random.bool(mob.chance * 100)) {
					spawnNpc(spawnPoint.x, spawnPoint.y, mob.npc);
					break;
				}
			}
		}
	}
	
	private function spawnNpc(x: Int, y: Int, npcData: CdbData.Npcs) {
		
		switch(npcData.id)
		{
			case CdbData.NpcsKind.Carrot:
				var mobSprite = new Carrot(x * levelData.props.tileSize, y * levelData.props.tileSize, npcData);
				npcSprites.add(mobSprite);
				npcShadowsSprites.add(new ShadowSprite(mobSprite));
			case CdbData.NpcsKind.Leek:
				var mobSprite = new Leek(x * levelData.props.tileSize, y * levelData.props.tileSize, npcData);
				npcSprites.add(mobSprite);
				npcShadowsSprites.add(new ShadowSprite(mobSprite));
			case CdbData.NpcsKind.Pepper:
				var mobSprite = new Pepper(x * levelData.props.tileSize, y * levelData.props.tileSize, npcData);
				npcSprites.add(mobSprite);
				npcFireBall.add(mobSprite.fireBall);
				npcShadowsSprites.add(new ShadowSprite(mobSprite));
			case CdbData.NpcsKind.Fish:
				var mobSprite = new IngredientEnemy(x * levelData.props.tileSize, y * levelData.props.tileSize, npcData);
				npcSprites.add(mobSprite);
				// No shadow for the fish
			default:
				var mobSprite = new IngredientEnemy(x * levelData.props.tileSize, y * levelData.props.tileSize, npcData);
				npcSprites.add(mobSprite);
				npcShadowsSprites.add(new ShadowSprite(mobSprite));
		}
		
		//var mobSprite = new FlxSprite(x * levelData.props.tileSize, y * levelData.props.tileSize);
		//mobSprite.drag.set(800, 800);
		//
		//mobSprite.loadGraphic("assets/" + npcData.image.file, true, npcData.image.size, npcData.image.size, false);
		//
		//for (anim in npcData.animations) {
			//trace(npcData.image);
			//mobSprite.animation.add(anim.name, [for(frame in anim.frames) frame.frame.x + frame.frame.y * stride], anim.frameRate);
		//}
		//
		//mobSprite.animation.play("idle");
		//npcSprites.add(mobSprite);
	}
	
	// the first tile id is 1
	private function computeMapOfProps(tileset:cdb.Data.TilesetProps): Void {
		for (i in 0...tileset.props.length) {
			var prop:Dynamic = tileset.props[i];
			if (prop != null) {
				mapOfProps[i + 1] = prop;
			}
		}
		
		//for (key in mapOfProps.keys()) {
			//trace('[prop] $key => ${mapOfProps[key]}');
		//}
	}
	
	// the first tile id is 0
	private function computeMapOfObjects(tileset:cdb.Data.TilesetProps): Void {
		for (set in tileset.sets) {
			switch(set.t) {
				case object:
					var tileId = (set.y * tileset.stride) + set.x;
					mapOfObjects[tileId] = set;
				case border:
					//
				case group:
					//
				case ground:
					//
				default:
					trace('unknown type :' + set);
			}
		}
		
		//for (key in mapOfObjects.keys()) {
			//trace('[object] $key => ${mapOfObjects[key]}');
		//}
	}
	
	private function processLayers(levelData:CdbData.LevelDatas):Void {
		for (layer in levelData.layers) {
			
			// Process the layer depending on the layer mode
			var mode:LayerMode = levelData.props.getLayer(layer.name).mode;
			switch(mode) {
				case LayerMode.Ground:
					trace('${layer.name}: Ground');
					processGroundLayer(layer, levelData);
				case LayerMode.Objects:
					trace('${layer.name}: Objects');
					processObjectLayer(layer, levelData);
				case LayerMode.Tiles:
					trace('${layer.name}: Tiles');
					// Never reached ? Tiles by default
					//processTileLayer(layer, levelData, tilemapOver); // TODO: just in case
				default:
					trace('${layer.name}: Default, probably Tiles');
					// TODO: Make generic
					processTileLayer(layer, levelData, tilemapOver);
			}
		}
	}
	
	private function processTileLayer(tileLayer: CdbData.LevelDatas_layers, levelData:CdbData.LevelDatas, tilemap:FlxTilemap):Void {
		tilemap.loadMapFromArray(tileLayer.data.data.decode(), levelData.width, levelData.height, "assets/" + tileLayer.data.file, tileLayer.data.size, tileLayer.data.size, FlxTilemapAutoTiling.OFF, 1);
	}
	
	private function processGroundLayer(groundLayer: CdbData.LevelDatas_layers, levelData:CdbData.LevelDatas):Void {
		// Simple ground
		processTileLayer(groundLayer, levelData, tilemapGround);
		
		// Borders
		var tileset = levelData.props.getTileset(CdbData.levelDatas, groundLayer.data.file);
		
		// TODO:
		// total argument seems useless, 624 in cdb (???), works for any value
		// at the end, groundMap.length = max(483, total+1)
		// (total number of tiles ? last tile id ?
		
		// /!\ This tileBuilder doesn't work the same as the Flixel one, it blends different tiles together /!\ 
		// There is not always a single tile per coordinate
		// (Comments in git/cdb/TileBuilder.hx laptop)
		
		var tileBuilder = new TileBuilder(tileset, groundLayer.data.stride, 0);
		var groundMapArray:Array<Int> = tileBuilder.buildGrounds(groundLayer.data.data.decode(), levelData.width);
		
		// TODO: array comprehension like above ?
		var groundBordersMapsData = new Array<Array<Int>>();
		
		// TODO: perfs
		// Create 4 tilemaps by default, more on the fly if needed
		for (i in 0...(ENABLE_MULTIPLE_GROUND_BORDER_TILEMAPS ? 4 : 1)) {
			var tempArray:Array<Int> = [for (i in 0...(levelData.width * levelData.height)) 0];
			groundBordersMapsData.push(tempArray);
		}
		
		var number:Int = Std.int(groundMapArray.length / 3);
		for (i in 0...number) {
			var x = groundMapArray[3*i];
			var y = groundMapArray[3*i + 1];
			var id = groundMapArray[3 * i + 2];
			
			var position = x + (y * levelData.width);
			
			// To check if the tile has been added
			var added = false;
			
			for (tempArray in groundBordersMapsData) {
				if (tempArray[position] == 0) {
					tempArray[position] = id;
					added = true;
					break;
				}
			}
			
			if (ENABLE_MULTIPLE_GROUND_BORDER_TILEMAPS && groundBordersMapsData.length < MAX_NUMBER_OF_GROUND_BORDER_TILEMAPS) {
				// If all the current tilemaps already contain something in the specified location, create a new one
				if (!added) {
					var tempArray:Array<Int> = [for (i in 0...(levelData.width * levelData.height)) 0];
					tempArray[position] = id;
					groundBordersMapsData.push(tempArray);
				}
			}
		}
		
		for (i in 0...groundBordersMapsData.length) {
			var groundBordersMapData:Array<Int> = groundBordersMapsData[i];
			var tilemapGroundBorders = new FlxTilemap();
			tilemapGroundBorders.loadMapFromArray(groundBordersMapData, levelData.width, levelData.height, "assets/" + groundLayer.data.file, groundLayer.data.size, groundLayer.data.size);			
			tilemapsGroundBorders.add(tilemapGroundBorders);
		}
		
		// TODO: move initialization ?
		arrayCollisions = [for (y in 0...levelData.height) [for (x in 0...levelData.width) null]];
		
		// Collisions
		for (y in 0...levelData.height) {
			for (x in 0...levelData.width) {
				var tileId:Int = tilemapGround.getTile(x, y);
				var prop:Dynamic = mapOfProps[tileId];
				if (prop != null && prop.collide != null && prop.collide == Full) {
					var groundCollisionObject = new FlxObject(x * groundLayer.data.size, y * groundLayer.data.size);
					groundCollisionObject.immovable = true;
					groundCollisionObject.allowCollisions = FlxObject.ANY;
					groundCollisionObject.setSize(groundLayer.data.size, groundLayer.data.size);
					groundCollisionObject.active = false;
					groundCollisionObject.moves = false;
					//groundCollisionObject.exists = false; // trop violent
					
					//trace('($x, $y) : $tileId => $prop');
					arrayCollisions[y][x] = groundCollisionObject;
				}
			}
		}
	}
	
	private function processObjectLayer(objectsLayer: CdbData.LevelDatas_layers, levelData:CdbData.LevelDatas):Void {
		var objectsDataMap:Array<Int> = [for (i in 0...(levelData.width * levelData.height)) 0];
		
		var tileset = levelData.props.getTileset(CdbData.levelDatas, objectsLayer.data.file);
		
		// TODO: supporter la superposition
		var objectsArray:Array<Int> = objectsLayer.data.data.decode();
		
		// Removing the leading 0xFFFF value
		objectsArray.shift();
		
		// Since there are 3 fields per objects (x, y, id), there are length/3 objects
		var numberOfObjects:Int = Std.int(objectsArray.length / 3);
		
		// TODO:
		// For rotated/flipped/animated tiles
		//var specialTiles:Array<FlxTileSpecial> = new Array<FlxTileSpecial>();
		
		for (i in 0...numberOfObjects) {
			var xValue = objectsArray[3*i];
			var yValue = objectsArray[3*i + 1];
			var idValue = objectsArray[3*i + 2];
			
			// TODO: x and y can actually be Floats
			// This just extracts the actual value (in pixel, not tile), ignoring the optional higher bit
			var x:Int = Std.int((xValue & ((1 << 15) - 1)) / objectsLayer.data.size);
			var y:Int = Std.int((yValue & ((1 << 15) - 1)) / objectsLayer.data.size);
			var id:Int = idValue & ((1 << 15) - 1);
			
			// These just check if the higher bit is set
			// TODO: Optimize ?
			// +90° rotation flag is encoded into the higher bit
			var rotate90:Bool = (xValue | (1 << 15)) == 1 << 15;
			
			// +180° rotation flag is encoded into the higher bit
			var rotate180:Bool = (yValue | (1 << 15)) == 1 << 15;
			
			// Horizontal flip flag is encoded into the higher bit
			var flip:Bool = (idValue | (1 << 15)) == 1 << 15;
			
			// Final rotation
			var rotation:Int = (rotate90 ? 1 : 0) + (rotate180 ? 2 : 0);
			
			// Sets all the tiles of the object (if width > 1 || height > 1)
			var set:Set = mapOfObjects[id];
			if (set != null) {
				for (dy in 0...set.h) {
					for (dx in 0...set.w) {
						var tempX:Int = x + dx;
						var tempY:Int = y + dy;
						var tempId:Int = id + dx + (tileset.stride * dy);
						objectsDataMap[tempX + (tempY * levelData.width)] = tempId;
					}
				}
			} else {
				// TODO:
			}
			
			// TODO: Take rotation/flip/animation in account
			//if (rotation != 0 || flip) {
				//var specialTile = new FlxTileSpecial(id, flip, false, rotation);
				//specialTiles.push(specialTile);
			//}
		}
		 //trace(objectsDataMap);
		tilemapObjects.loadMapFromArray(objectsDataMap, levelData.width, levelData.height, "assets/" + objectsLayer.data.file, objectsLayer.data.size, objectsLayer.data.size, FlxTilemapAutoTiling.OFF, 0);
		//tilemapObjects.setSpecialTiles(specialTiles);
		
		for (y in 0...levelData.height) {
			for (x in 0...levelData.width) {
				
				var tileId:Int = tilemapObjects.getTile(x, y);
				
				// 0 means there is no tile, so we skip
				if (tileId == 0) {
					continue;
				}
				
				// Increment because the tilesheet is 1-based
				tileId++;
				
				var prop:Dynamic = mapOfProps[tileId];
				
				var objectSprite:FlxSprite = tilemapObjects.tileToSprite(x, y, 0, function(tileProperty:FlxTileProperties) {
					var sprite = new FlxSprite(x * objectsLayer.data.size, y * objectsLayer.data.size);
					sprite.frame = tileProperty.graphic.frame;
					sprite.immovable = true;
					sprite.allowCollisions = FlxObject.NONE;
					sprite.active = false;
					sprite.moves = false;
					sprite.setSize(objectsLayer.data.size, objectsLayer.data.size);
					
					return sprite;
				});
				
				//trace('($x, $y) : $prop');
				
				if (prop == null || prop.hideHero == null || prop.hideHero == 0) {
					groundObjectsGroup.add(objectSprite);
				} else if (prop.hideHero == 2) {
					overObjectsGroup.add(objectSprite);
				} else {
					objectsGroup.add(objectSprite);
				}
				
				if (prop != null && prop.collide != null) {
					
					objectSprite.allowCollisions = FlxObject.ANY;
					
					// If there already was a collision information for this coordinate, we discard it
					// Object collision overrides ground collisions (ex: bridge)
					arrayCollisions[y][x] = null;
					
					switch(prop.collide) {
						case Full:
							// Default
							
						case Small:
							// USE RESET
							// If you just set x and y, "last" is not updated and fucks up collisions
							
							var offsetX = objectsLayer.data.size / 4;
							var offsetY = objectsLayer.data.size / 4;
							var sizeX = objectsLayer.data.size / 2;
							var sizeY = objectsLayer.data.size / 2;
							
							objectSprite.reset(objectSprite.x + offsetX, objectSprite.y + offsetY);
							objectSprite.setSize(sizeX, sizeY);
							objectSprite.offset.set(offsetX, offsetY);
							
						case No:
							//trace(prop);
							objectSprite.allowCollisions = FlxObject.NONE;
							
						case Top:
							var offsetX = 0;
							var offsetY = 0;
							var sizeX = objectsLayer.data.size;
							var sizeY = objectsLayer.data.size / 4;
							
							objectSprite.reset(objectSprite.x + offsetX, objectSprite.y + offsetY);
							objectSprite.setSize(sizeX, sizeY);
							objectSprite.offset.set(offsetX, offsetY);
							
						case Right:
							var offsetX = objectsLayer.data.size - (objectsLayer.data.size / 4);
							var offsetY = 0;
							var sizeX = objectsLayer.data.size / 4;
							var sizeY = objectsLayer.data.size;
							
							objectSprite.reset(objectSprite.x + offsetX, objectSprite.y + offsetY);
							objectSprite.setSize(sizeX, sizeY);
							objectSprite.offset.set(offsetX, offsetY);
							
						case Bottom:
							var offsetX = 0;
							var offsetY = objectsLayer.data.size - (objectsLayer.data.size / 4);
							var sizeX = objectsLayer.data.size;
							var sizeY = objectsLayer.data.size / 4;
							
							objectSprite.reset(objectSprite.x + offsetX, objectSprite.y + offsetY);
							objectSprite.setSize(sizeX, sizeY);
							objectSprite.offset.set(offsetX, offsetY);
							
						case Left:
							var offsetX = 0;
							var offsetY = 0;
							var sizeX = objectsLayer.data.size / 4;
							var sizeY = objectsLayer.data.size;
							
							objectSprite.reset(objectSprite.x + offsetX, objectSprite.y + offsetY);
							objectSprite.setSize(sizeX, sizeY);
							objectSprite.offset.set(offsetX, offsetY);
							
						case HalfTop:
							var offsetX = 0;
							var offsetY = 0;
							var sizeX = objectsLayer.data.size;
							var sizeY = objectsLayer.data.size / 2;
							
							objectSprite.reset(objectSprite.x + offsetX, objectSprite.y + offsetY);
							objectSprite.setSize(sizeX, sizeY);
							objectSprite.offset.set(offsetX, offsetY);
							
						case HalfBottom:
							var offsetX = 0;
							var offsetY = objectsLayer.data.size / 2;
							var sizeX = objectsLayer.data.size;
							var sizeY = objectsLayer.data.size / 2;
							
							objectSprite.reset(objectSprite.x + offsetX, objectSprite.y + offsetY);
							objectSprite.setSize(sizeX, sizeY);
							objectSprite.offset.set(offsetX, offsetY);
							
						case HalfLeft:
							var offsetX = 0;
							var offsetY = 0;
							var sizeX = objectsLayer.data.size / 2;
							var sizeY = objectsLayer.data.size;
							
							objectSprite.reset(objectSprite.x + offsetX, objectSprite.y + offsetY);
							objectSprite.setSize(sizeX, sizeY);
							objectSprite.offset.set(offsetX, offsetY);
							
						case HalfRight:
							var offsetX = objectsLayer.data.size / 2;
							var offsetY = 0;
							var sizeX = objectsLayer.data.size / 2;
							var sizeY = objectsLayer.data.size;
							
							objectSprite.reset(objectSprite.x + offsetX, objectSprite.y + offsetY);
							objectSprite.setSize(sizeX, sizeY);
							objectSprite.offset.set(offsetX, offsetY);
							
						case Vertical:
							var offsetX = objectsLayer.data.size / 3;
							var offsetY = 0;
							var sizeX = objectsLayer.data.size / 4;
							var sizeY = objectsLayer.data.size;
							
							objectSprite.reset(objectSprite.x + offsetX, objectSprite.y + offsetY);
							objectSprite.setSize(sizeX, sizeY);
							objectSprite.offset.set(offsetX, offsetY);
							
						case Horizontal:
							var offsetX = 0;
							var offsetY = objectsLayer.data.size / 3;
							var sizeX = objectsLayer.data.size;
							var sizeY = objectsLayer.data.size / 4;
							
							objectSprite.reset(objectSprite.x + offsetX, objectSprite.y + offsetY);
							objectSprite.setSize(sizeX, sizeY);
							objectSprite.offset.set(offsetX, offsetY);
							
						case SmallTR:
							var offsetX = objectsLayer.data.size - (objectsLayer.data.size / 4);
							var offsetY = 0;
							var sizeX = objectsLayer.data.size / 4;
							var sizeY = objectsLayer.data.size / 4;
							
							objectSprite.reset(objectSprite.x + offsetX, objectSprite.y + offsetY);
							objectSprite.setSize(sizeX, sizeY);
							objectSprite.offset.set(offsetX, offsetY);
							
						case SmallBR:
							var offsetX = objectsLayer.data.size - (objectsLayer.data.size / 4);
							var offsetY = objectsLayer.data.size - (objectsLayer.data.size / 4);
							var sizeX = objectsLayer.data.size / 4;
							var sizeY = objectsLayer.data.size / 4;
							
							objectSprite.reset(objectSprite.x + offsetX, objectSprite.y + offsetY);
							objectSprite.setSize(sizeX, sizeY);
							objectSprite.offset.set(offsetX, offsetY);
							
						case SmallBL:
							var offsetX = 0;
							var offsetY = objectsLayer.data.size - (objectsLayer.data.size / 4);
							var sizeX = objectsLayer.data.size / 4;
							var sizeY = objectsLayer.data.size / 4;
							
							objectSprite.reset(objectSprite.x + offsetX, objectSprite.y + offsetY);
							objectSprite.setSize(sizeX, sizeY);
							objectSprite.offset.set(offsetX, offsetY);
							
						case SmallTL:
							var offsetX = 0;
							var offsetY = 0;
							var sizeX = objectsLayer.data.size / 4;
							var sizeY = objectsLayer.data.size / 4;
							
							objectSprite.reset(objectSprite.x + offsetX, objectSprite.y + offsetY);
							objectSprite.setSize(sizeX, sizeY);
							objectSprite.offset.set(offsetX, offsetY);
							
						case CornerTR:
							// TODO: horrible
							var tempSprite = new FlxSprite(objectSprite.x, objectSprite.y);
							tempSprite.makeGraphic(objectsLayer.data.size, objectsLayer.data.size, FlxColor.TRANSPARENT);
							tempSprite.immovable = true;
							tempSprite.allowCollisions = FlxObject.ANY;
							tempSprite.active = false;
							tempSprite.moves = false;
							
							// TOP
							var offsetX = 0;
							var offsetY = 0;
							var sizeX = objectsLayer.data.size;
							var sizeY = objectsLayer.data.size / 4;
							
							objectSprite.reset(objectSprite.x + offsetX, objectSprite.y + offsetY);
							objectSprite.setSize(sizeX, sizeY);
							objectSprite.offset.set(offsetX, offsetY);
							
							// RIGHT
							var offsetX2 = objectsLayer.data.size - (objectsLayer.data.size / 4);
							var offsetY2 = 0;
							var sizeX2 = objectsLayer.data.size / 4;
							var sizeY2 = objectsLayer.data.size;
							
							tempSprite.reset(tempSprite.x + offsetX2, tempSprite.y + offsetY2);
							tempSprite.setSize(sizeX2, sizeY2);
							tempSprite.offset.set(offsetX2, offsetY2);
							
							objectsGroup.add(tempSprite);
							
						case CornerBR:
							// TODO: horrible
							var tempSprite = new FlxSprite(objectSprite.x, objectSprite.y);
							tempSprite.makeGraphic(objectsLayer.data.size, objectsLayer.data.size, FlxColor.TRANSPARENT);
							tempSprite.immovable = true;
							tempSprite.allowCollisions = FlxObject.ANY;
							tempSprite.active = false;
							tempSprite.moves = false;
							
							// BOTTOM
							var offsetX = 0;
							var offsetY = objectsLayer.data.size - (objectsLayer.data.size / 4);
							var sizeX = objectsLayer.data.size;
							var sizeY = objectsLayer.data.size / 4;
							
							objectSprite.reset(objectSprite.x + offsetX, objectSprite.y + offsetY);
							objectSprite.setSize(sizeX, sizeY);
							objectSprite.offset.set(offsetX, offsetY);
							
							// RIGHT
							var offsetX2 = objectsLayer.data.size - (objectsLayer.data.size / 4);
							var offsetY2 = 0;
							var sizeX2 = objectsLayer.data.size / 4;
							var sizeY2 = objectsLayer.data.size;
							
							tempSprite.reset(tempSprite.x + offsetX2, tempSprite.y + offsetY2);
							tempSprite.setSize(sizeX2, sizeY2);
							tempSprite.offset.set(offsetX2, offsetY2);
							
							objectsGroup.add(tempSprite);
							
						case CornerBL:
							// TODO: horrible
							var tempSprite = new FlxSprite(objectSprite.x, objectSprite.y);
							tempSprite.makeGraphic(objectsLayer.data.size, objectsLayer.data.size, FlxColor.TRANSPARENT);
							tempSprite.immovable = true;
							tempSprite.allowCollisions = FlxObject.ANY;
							tempSprite.active = false;
							tempSprite.moves = false;
							
							// BOTTOM
							var offsetX = 0;
							var offsetY = objectsLayer.data.size - (objectsLayer.data.size / 4);
							var sizeX = objectsLayer.data.size;
							var sizeY = objectsLayer.data.size / 4;
							
							objectSprite.reset(objectSprite.x + offsetX, objectSprite.y + offsetY);
							objectSprite.setSize(sizeX, sizeY);
							objectSprite.offset.set(offsetX, offsetY);
							
							// LEFT
							var offsetX2 = 0;
							var offsetY2 = 0;
							var sizeX2 = objectsLayer.data.size / 4;
							var sizeY2 = objectsLayer.data.size;
							
							tempSprite.reset(tempSprite.x + offsetX2, tempSprite.y + offsetY2);
							tempSprite.setSize(sizeX2, sizeY2);
							tempSprite.offset.set(offsetX2, offsetY2);
							
							objectsGroup.add(tempSprite);
							
						case CornerTL:
							// TODO: horrible
							var tempSprite = new FlxSprite(objectSprite.x, objectSprite.y);
							tempSprite.makeGraphic(objectsLayer.data.size, objectsLayer.data.size, FlxColor.TRANSPARENT);
							tempSprite.immovable = true;
							tempSprite.allowCollisions = FlxObject.ANY;
							tempSprite.active = false;
							tempSprite.moves = false;
							
							// TOP
							var offsetX = 0;
							var offsetY = 0;
							var sizeX = objectsLayer.data.size;
							var sizeY = objectsLayer.data.size / 4;
							
							objectSprite.reset(objectSprite.x + offsetX, objectSprite.y + offsetY);
							objectSprite.setSize(sizeX, sizeY);
							objectSprite.offset.set(offsetX, offsetY);
							
							// LEFT
							var offsetX2 = 0;
							var offsetY2 = 0;
							var sizeX2 = objectsLayer.data.size / 4;
							var sizeY2 = objectsLayer.data.size;
							
							tempSprite.reset(tempSprite.x + offsetX2, tempSprite.y + offsetY2);
							tempSprite.setSize(sizeX2, sizeY2);
							tempSprite.offset.set(offsetX2, offsetY2);
							
							objectsGroup.add(tempSprite);
							
						// TODO: One is WALL (LEFT | RIGHT), the other is TOP | DOWN, but I don't know yet which is which
						case Ladder:
							objectSprite.allowCollisions = FlxObject.LEFT | FlxObject.RIGHT; // ie FlxObject.WALL
							
						case VLadder:
							objectSprite.allowCollisions = FlxObject.UP | FlxObject.DOWN;
							
						default: 
							objectSprite.allowCollisions = FlxObject.NONE;
							//trace('($x, $y) : $tileId => $prop');
					}
				} else {
					// No object with collision at this position
					//trace('($x, $y)');
				}
			}
		}
	}
	
	private function processTriggerZones(triggers:ArrayRead < CdbData.LevelDatas_triggers > ):Void {
		for (trigger in triggers) {
			switch(trigger.action) {
				case CdbData.Action.Anchor(id):
					// Spawn point
					trace('Anchor - id: [$id]');
					
					mapOfAnchor.set(id, new FlxPoint(trigger.x, trigger.y));
					
					// Une des commandes client
					if (StringTools.startsWith(id, "Client")) {
						var sprite = new FlxSprite(trigger.x * levelData.props.tileSize + 12, trigger.y * levelData.props.tileSize);
						sprite.makeGraphic(levelData.props.tileSize * trigger.width, levelData.props.tileSize * trigger.height, FlxColor.TRANSPARENT);
						sprite.setSize(levelData.props.tileSize * trigger.width / 4, levelData.props.tileSize * trigger.height / 4);
						sprite.immovable = true;
						sprite.active = false;
						sprite.moves = false;
						//sprite.allowCollisions = FlxObject.NONE;
						
						commandTriggers.add(sprite);
						mapOfCommands.set(sprite, Std.parseInt(id.charAt(6)) - 1);
					}
					
				case CdbData.Action.Goto(l, anchor):
					// Departure point
					trace('Goto - l: [$l] - anchor: [$anchor]');
					
					var sprite = new FlxSprite(trigger.x * levelData.props.tileSize, trigger.y * levelData.props.tileSize);
					sprite.setSize(levelData.props.tileSize * trigger.width, levelData.props.tileSize * trigger.height);
					sprite.makeGraphic(levelData.props.tileSize * trigger.width, levelData.props.tileSize * trigger.height, FlxColor.TRANSPARENT);
					sprite.immovable = true;
					sprite.active = false;
					sprite.moves = false;
					//sprite.allowCollisions = FlxObject.NONE;
					
					var goto:Goto = {l: l, anchor: anchor};
					
					changeScreenTriggers.add(sprite);
					mapOfGoto.set(sprite, goto);
					
				default: 
					//
			}
		}
	}
	
	private function traceLayers(levelData:CdbData.LevelDatas):Void {
		// List of layers in the "layers" column
		for (layer in levelData.layers) {
			trace("name : " + layer.name);
			// String, name of the layer
			
			trace("blending: " + layer.blending);
			// Enumeration (Add, Multiply, Erase) ?
			
			trace("file : " + layer.data.file);
			// String, name of the tileset file
			
			trace("size : " + layer.data.size);
			// Int, size of the tiles in the tileset
			
			trace("stride : " + layer.data.stride);
			// Int, width (in tiles) of the tilesheet
			
			trace("data : " + layer.data.data.decode());
			// Array<Int>
			// either width x height with tile id as a value (ground/tile)
			// or 0xFFFF (65535) to indicate object array, then numberOfObjects x 3 (x, y, top left id)
			
			trace("");
		}
	}
	
	private function traces(levelData:CdbData.LevelDatas):Void {
		trace("items : ");
		//for (item in CdbData.items.all) {
			//trace(item);
		//}
		trace("npcs : ");
		for (npc in CdbData.npcs.all) {
			trace(npc);
		}
		trace("collides :");
		for (collide in CdbData.collides.all) {
			trace(collide);
		}
		
		//trace(CdbData.ItemsKind);
		//trace(CdbData.items.get(CdbData.ItemsKind.Sword));
		//trace(CdbData.items.resolve("Sword"));
		
		// Ok
		//trace(CdbData.items.resolve("Guinea Pig", true));
		
		// Would crash because there is no "Guinea Pig" object (sadly)
		//trace(CdbData.items.resolve("Guinea Pig", false));
		
		//trace(forestTileset.props.length);
		//trace(forestTileset.sets.length);
		
		//CdbData.collides.all
		//CdbData.levelDatas.get().collide.
		//var ertert:Layer<Collides>;
		
		//trace("sets:");
		//trace(levelData.collide.decode());
		
		//levelData.props.getLayer("ground").alpha
		//levelData.props.tileSize
		
		//var something:cdb.CdbData.SOME_TYPE;
	}
	
}