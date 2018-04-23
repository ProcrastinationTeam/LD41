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

	
}