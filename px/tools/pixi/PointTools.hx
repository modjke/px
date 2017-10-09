package  px.tools.pixi;
import pixi.core.math.Point;


class PointTools
{

	public static inline function sub(a:Point, b:Point)
	{
		return new Point(a.x - b.x, a.y - b.y);
	}
	
	public static inline function add(a:Point, b:Point)
	{
		return new Point(a.x + b.x, a.y + b.y);
	}
}