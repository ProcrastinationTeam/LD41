package;

import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

/**
 * ...
 * @author ElRyoGrande
 */
class PlayerHUD extends FlxSpriteGroup 
{
	
	public var healthText : FlxText;
	public var healthString: String;
	
	public function new(player: Player) 
	{
		super();
		healthString = "HEALTH: ";
		healthText = new FlxText(5, 26, 0, healthString + Storage.player1Stats.currentHealth + "%", 8);
		healthText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.RED, 1, 1);
		add(healthText);
	}
	
	override public function update(elapsed : Float)
	{
		super.update(elapsed);
		
		healthText.text = healthString + Storage.player1Stats.currentHealth + "%";
		
	}
	
	

	
}