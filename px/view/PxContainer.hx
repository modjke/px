package px.view;

import pixi.core.math.Point;
import pixi.core.display.Container;
import pixi.core.display.DisplayObject;
import pixi.core.graphics.Graphics;
import pixi.core.math.shapes.Rectangle;

class PxContainer extends Container 
{

	@:keep
	public var scaleX(get, set):Float;	
	function get_scaleX() return scale.x;
	function set_scaleX(v:Float) return scale.x = v;
	
	@:keep
	public var scaleY(get, set):Float;
	function get_scaleY() return scale.y;
	function set_scaleY(v:Float) return scale.y = v;
	
	
	/**
	 * TODO: Move to Psd2Px stuff
	 * @param	children
	 * @param	alignTopLeft
	 * @param	insideContainer
	 * @return
	 */
	public function contain<T:DisplayObject>(children:Array<T>, alignTopLeft:Bool = false, ?insideContainer:PxContainer):PxContainer
	{
		var out = insideContainer != null ? insideContainer : new PxContainer();
		if (alignTopLeft)
		{
			out.x = children[0].x;		
			out.y = children[0].y;
		}
		
		for (c in children)
		{
			if (c.parent != null && c.parent != this) throw "At least one of the children is not from this container";
			
			if (alignTopLeft)
			{
				if (out.x > c.x) out.x = c.x;
				if (out.y > c.y) out.y = c.y;
			}
			
			c.setParent(out);
		}
		
		if (alignTopLeft)
			for (c in children)
			{
				c.x -= out.x;
				c.y -= out.y;
			}
		
		
		return out;		
	}
	
	/**
	 * TODO: Move to Psd2Px stuff
	 * @param	points
	 * @param	outBounds
	 * @param	alightTopLeft
	 * @return
	 */
	public static function createMaskGraphics(points:Array<Point>, ?outBounds:Rectangle, alightTopLeft:Bool = true, maskColor:Int = 0x000000):Graphics
	{		
		var last = points[points.length - 1];
		var tl = new Point(last.x, last.y);
		var br = new Point(last.x, last.y);
		
		for (p in points)
		{
			if (p.x < tl.x) tl.x = p.x;
			if (p.x > br.x) br.x = p.x;
			if (p.y < tl.y) tl.y = p.y;
			if (p.y > br.y) br.y = p.y;
		}
		
		var g = new Graphics();
		if (alightTopLeft)
		{
			g.x = tl.x;
			g.y = tl.y;
		}
		
		
		g.beginFill(maskColor);
		g.moveTo(last.x - g.x, last.y - g.y);
		
		for (p in points)		
			g.lineTo(p.x - g.x, p.y - g.y);		
		
		g.endFill();

		var b = outBounds != null ? outBounds : new Rectangle(0, 0, 0, 0);
		b.x = tl.x - g.x;
		b.y = tl.y - g.y;
		b.width = br.x - tl.x;
		b.height = br.y - tl.y;		
		
		return g;
	}
	
	public function new() 
	{
		super();
		
	}
	
}