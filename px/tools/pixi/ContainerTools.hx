package px.tools.pixi;
import pixi.core.display.Container;
import pixi.core.display.DisplayObject;
import pixi.core.math.Point;
import pixi.core.math.shapes.Rectangle;


class ContainerTools
{
	public static inline function setAlpha<T:Container>(container:T, a:Float):T 
	{
		container.alpha = a;
		return container;
	}
	
	public static inline function disableInteraction<T:Container>(container:T):T
	{
		container.interactive = false;
		container.interactiveChildren = false;
		container.hitArea = ZERO_RECT;		
		return container;
	}
	
	public static inline function matchChildrenByName<T:Container>(container:T, regEx:EReg, invertMatch:Bool = false):Array<DisplayObject>
	{		
		return container.children.filter(function (c) return invertMatch ? !regEx.match(c.name) : regEx.match(c.name));
	}	
	
	public static inline function insertChildUnder<T:Container>(container:T, child:DisplayObject, under:DisplayObject)
	{
		if (under.parent != container) throw '<under> is not inside this container';
		
		container.addChild(child);
		var index = container.getChildIndex(child);
		while (index-- > 0)
		{
			var swapWith = container.getChildAt(index);
			container.swapChildren(swapWith, child);
			
			if (swapWith == under) break;
		}
	}
	
	public static inline function insertChildOnTopOf<T:Container>(container:T, child:DisplayObject, on:DisplayObject)
	{
		if (on.parent != container) throw '<on> is not inside this container';
		
		container.addChild(child);
		var index = container.getChildIndex(child);
		while (index-- > 0)
		{
			var swapWith = container.getChildAt(index);
			if (swapWith == on) break;
			
			container.swapChildren(swapWith, child);			
		}
	}
	
	
	static var ZERO_RECT = new Rectangle(0, 0, 0, 0);
	

	public static inline function centerAt<T:Container>(container:T, x:Float, y:Float):T 
	{
		container.x = x - container.width * .5;
		container.y = y - container.height * .5;
		return container;
	}
	
	public static inline function centerAtPoint<T:Container>(container:T, p:Point):T 
	{
		container.x = p.x - container.width * .5;
		container.y = p.y - container.height * .5;
		return container;
	}
	
	public static inline function setPivot<T:Container>(container:T, h:Float, v:Float, adjustPosition = false):T
	{
		container.pivot.set(h * container.width / container.scale.x, v * container.height / container.scale.y);
		if (adjustPosition) {
			container.x += container.pivot.x * container.scale.x;
			container.y += container.pivot.y * container.scale.y;
		}
		return container;
	}
	
	public static inline function setPivotAbs<T:Container>(container:T, v:Float, h:Float, adjustPosition = false):T
	{
		container.pivot.set(v, h);
		if (adjustPosition) {
			container.x += container.pivot.x;
			container.y += container.pivot.y;
		}
		return container;
	}

	public static inline function centerPivot<T:Container>(container:T, adjustPosition = false):T
	{
		return setPivot(container, 0.5, 0.5, adjustPosition);
	}
	
	public static inline function getCenter<T:Container>(container:T):Point
	{
		var bounds = container.getLocalBounds();
		return new Point(container.x + bounds.x + bounds.width * .5, container.y + bounds.y + bounds.height * .5);
	}
	
	public static inline function translateX<T:Container>(c:T, tx:Float)
	{
		c.x += tx;
		return c;
	}
	
	public static inline function translateY<T:Container>(c:T, ty:Float)
	{
		c.y += ty;
		return c;
	}
	
	public static inline function getBottom<T:Container>(c:T):Float
	{
		var bounds = c.getLocalBounds();
		return bounds.y + bounds.height;
	}
}