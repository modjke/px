package  px.tools.pixi;
import pixi.core.math.Point;
import pixi.core.math.shapes.Rectangle;
import pixi.core.sprites.Sprite;

class SpriteTools
{
	
	public static inline function setAlpha<T:Sprite>(sprite:T, a:Float):T 
	{
		sprite.alpha = a;
		return sprite;
	}
	
	
	public static inline function centerAt<T:Sprite>(sprite:T, x:Float, y:Float):T 
	{
		sprite.x = x - sprite.width * .5;
		sprite.y = y - sprite.height * .5;
		return sprite;
	}
	
	public static inline function getCenter<T:Sprite>(sprite:T):Point
	{
		return new Point(sprite.x + sprite.width * .5 - sprite.pivot.x, sprite.y + sprite.height * .5 - sprite.pivot.y);
	}
	
	public static inline function disableInteraction<T:Sprite>(sprite:T):T
	{
		sprite.interactive = false;
		sprite.interactiveChildren = false;
		sprite.hitArea = ZERO_RECT;		
		return sprite;
	}
	
	static var ZERO_RECT = new Rectangle(0, 0, 0, 0);
}