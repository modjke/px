package  px.tools.pixi;
import pixi.core.display.Container;
import pixi.core.display.DisplayObject;
import pixi.core.math.Point;
import pixi.core.math.shapes.Rectangle;
import pixi.interaction.InteractionEvent;

class DisplayObjectTools
{

	public static inline function setPosition<T:DisplayObject>(sprite:T, x:Float, y:Float):T 
	{
		sprite.position.set(x, y);
		return sprite;
	}
	
	public static inline function setBottom<T:DisplayObject>(sprite:T, bottom:Float):T 
	{
		sprite.y = bottom - sprite.getLocalBounds().height - sprite.pivot.y;
		return sprite;
	}
	
	public static inline function setRight<T:DisplayObject>(sprite:T, right:Float):T 
	{
		sprite.x = right - sprite.getLocalBounds().width - sprite.pivot.x;
		return sprite;
	}
	
	public static inline function setLeft<T:DisplayObject>(sprite:T, left:Float):T 
	{
		sprite.x = left + sprite.pivot.x;
		return sprite;
	}
	
	public static inline function setTop<T:DisplayObject>(sprite:T, top:Float):T 
	{
		sprite.y = top + sprite.pivot.y;
		return sprite;
	}
	
	
	public static inline function setVCenter<T:DisplayObject>(sprite:T, vCenter:Float):T 
	{
		var bounds = sprite.getLocalBounds();
		sprite.y = vCenter + bounds.y - bounds.height * .5;
		return sprite;
	}
	
	public static inline function setHCenter<T:DisplayObject>(sprite:T, hCenter:Float):T 
	{
		var bounds = sprite.getLocalBounds();
		sprite.x = hCenter + bounds.x - bounds.width * .5;
		return sprite;
	}
	
	
	
	public static inline function setVisible<T:DisplayObject>(sprite:T, v:Bool):T 
	{
		sprite.visible = v;
		return sprite;
	}
	
	public static inline function setPositionFrom<T:DisplayObject>(sprite:T, pos:Point):T 
	{
		sprite.position.copy(pos);
		return sprite;
	}
	
	public static inline function addTo<T:DisplayObject>(sprite:T, parent:Container, ?atIndex:Int):T
	{
		if (atIndex == null)
			parent.addChild(sprite);
		else
			parent.addChildAt(sprite, atIndex);
			
		return sprite;
	}
	
	public static inline function setClickHandler<T:DisplayObject>(sprite:T, handler:InteractionEvent->Void, asButton = false, autoHitArea = false):T
	{
		sprite.interactive = true;
		sprite.buttonMode = asButton;
		sprite.click = sprite.tap = handler;
		if (autoHitArea)
		{
			sprite.hitArea = sprite.getLocalBounds();						
		}
		
		return sprite;
	}
	
	public static inline function setRotation<T:DisplayObject>(sprite:T, angle:Float):T 
	{
		sprite.rotation = angle;
		return sprite;
	}
	
}