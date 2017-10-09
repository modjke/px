package px.utils;
import pixi.core.math.Point;
import pixi.core.textures.Texture;


/**
 * Hacky way to set default pivot & default anchor
 * TODO: find a better way to do this
 */
class PxTextureUtils 
{

	public static function setDefaultPivot(texture:Texture, x:Float, y:Float)
	{
		if (texture == null) throw "Texture is null";
		untyped texture.__px__defaultPivot = { x: x, y: y };
	}
	
	public static function setDefaultAnchor(texture:Texture, x:Float, y:Float)
	{
		if (texture == null) throw "Texture is null";
		untyped texture.__px__defaultAnchor = { x: x, y: y };
	}
	
	public static function getDefaultPivot(texture:Texture, ?pivot:{x:Float, y:Float }):{x:Float, y:Float }
	{
		if (texture == null) throw "Texture is null";
		
		if (pivot == null)
			pivot = {x:0, y:0};
			
		var defaultPivot:{ x:Float, y:Float } = untyped texture.__px__defaultPivot;
		if (defaultPivot != null)
		{
			pivot.x = defaultPivot.x;
			pivot.y = defaultPivot.y;
		}
		
		return pivot;
	}
	
	public static function getDefaultAnchor(texture:Texture, ?anchor:{x:Float, y:Float }):{x:Float, y:Float}
	{
		if (texture == null) throw "Texture is null";
		
		if (anchor == null)
			anchor = { x: 0, y: 0 };
			
		var defaultAnchor:{ x:Float, y:Float } = untyped texture.__px__defaultAnchor;
		if (defaultAnchor != null)
		{
			anchor.x = defaultAnchor.x;
			anchor.y = defaultAnchor.y;
		}
		
		return anchor;
	}
}