package;

/**
 * ...
 * @author ElRyoGrande
 */
class Storage 
{

	public static var recipe1 : Array<CdbData.IngredientsKind> = new Array<CdbData.IngredientsKind>();
	public static var recipe2 : Array<CdbData.IngredientsKind> = new Array<CdbData.IngredientsKind>();
	public static var recipe3 : Array<CdbData.IngredientsKind> = new Array<CdbData.IngredientsKind>();
	public static var recipe1name : String;
	public static var recipe2name : String;
	public static var recipe3name : String;
	
	public static var player1Stats: PlayerStatWrapper = new PlayerStatWrapper();
	
	
	public static var ingredientsCount : Map<CdbData.IngredientsKind,Int> = new Map<CdbData.IngredientsKind,Int>();
	
	
	public static var nbCustomer : Int;
	public static var customerArray : Array<Customer>;
	
	public static var timerArray : Array<Float>;
	public static var positionArray : Array<Float>;
	public static var speedArray : Array<Float>;
	
	public static var timer : Float = 0;

	public static function reset() {
		recipe1 = new Array<CdbData.IngredientsKind>();
		recipe2 = new Array<CdbData.IngredientsKind>();
		recipe3 = new Array<CdbData.IngredientsKind>();
		recipe1name = null;
		recipe2name = null;
		recipe3name = null;
		
		player1Stats = new PlayerStatWrapper();
		
		ingredientsCount = new Map<CdbData.IngredientsKind,Int>();
		
		nbCustomer = 0;
		customerArray = null;
		
		timerArray = null;
		positionArray = null;
		speedArray = null;
		
		timer = 0;
	}
	
}