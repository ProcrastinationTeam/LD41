package;

import flixel.FlxSprite;

class Pickup extends FlxSprite
{
	public var money : Float;
	
	public function new(pickup:CdbData.LevelDatas_pickups)
	{
		var pickupData = CdbData.pickups.get(pickup.kindId);
		var pickupsTileset:cdb.Data.TilesetProps = CdbData.levelDatas.get(CdbData.LevelDatasKind.FirstVillage).props.getTileset(CdbData.levelDatas, pickupData.image.file);
		
		super(pickup.x * pickupData.image.size, pickup.y * pickupData.image.size);
		
		// TODO: re use AssetPaths ?
		loadGraphic("assets/" + pickupData.image.file, true, pickupData.image.size, pickupData.image.size);
		animation.frameIndex = pickupData.image.x + pickupData.image.y * pickupsTileset.stride;
		
		money = pickupData.money;
	}
}