package px.view;
import js.Browser;
import js.html.CanvasElement;
import pixi.core.display.DisplayObject;
import pixi.core.math.Matrix;
import pixi.core.math.Point;
import pixi.core.math.shapes.Rectangle;
import pixi.core.sprites.Sprite;
import pixi.core.textures.Texture;
import px.utils.PxScreenshot;
import thx.color.Rgba;

class PxStage extends PxContainer 
{

	public function new() 
	{
		super();
		
		
	}
	
	
	/**
	 * 
	 * @param	x point to test in stage coordinate space
	 * @param	y point to test in stage coordinate space
	 * @param	object object to test
	 * @return  alpha value of that pixel [0...255]
	 */	
	var __point:Point = new Point();
	public function colorHitTest(x:Float, y:Float, object:Sprite):Rgba
	{
		__point.set(x, y);
		worldTransform.apply(__point, __point);
		object.worldTransform.applyInverse(__point, __point);
		
		var w:Float = object.texture.width;
		var h:Float = object.texture.height;
		__point.x += w * object.anchor.x;
		__point.y += h * object.anchor.y;
		
		if (__point.x < 0 || __point.x >= w ||
			__point.y < 0 || __point.y >= h)
			return 0;
			
		
		var canvas = textureToCanvas(object.texture);
	
		var imageData = canvas.getContext2d().getImageData(Std.int(__point.x), Std.int(__point.y), 1, 1).data;
		
		return Rgba.create(imageData[0], imageData[1], imageData[2], imageData[3]);
	}
	
	inline static function textureToCanvas(texture:Texture):CanvasElement
	{
		var sprite = new Sprite(texture);
		var canvas = Px.renderer.plugins.extract.canvas(sprite);
		sprite.destroy( { texture: false, baseTexture: false });
		return canvas;
	}

	
	
	public function getBoundsOf(displayObject:DisplayObject, ?rect:Rectangle, skipUpdate = true):Rectangle
	{
		if (rect == null) rect = new Rectangle();
		
		displayObject.getBounds(skipUpdate, rect);			
		applyInverseMatrix(worldTransform, rect);
		
		
		return rect;
	}
	
	
	function applyMatrix(m:Matrix, r:Rectangle)
	{
		var x0 = r.left;
		var y0 = r.top;
		var x1 = r.right;
		var y1 = r.bottom;
		
		r.x = m.a * x0 + m.c * y0 + m.tx;
		r.y = m.b * x0 + m.d * y0 + m.ty;
		
		r.width = m.a * x1 + m.c * y1 + m.tx - r.x;
		r.height = m.b * x1 + m.d * y1 + m.ty - r.y;
		
		if (r.width < 0) 
		{
			r.x += r.width;
			r.width *= -1;
		}
		
		if (r.height < 0)
		{
			r.y += r.height;
			r.height *= -1;
		}
	}
	
	function applyInverseMatrix(m:Matrix, r:Rectangle)
	{
		var id = 1 / (m.a * m.d + m.c * -m.b);
		var dx = (m.ty * m.c - m.tx * m.d) * id;
		var dy = ( -m.ty * m.a + m.tx * m.b) * id;
		
		var x0 = r.x;
		var y0 = r.y;
		var x1 = r.x + r.width;
		var y1 = r.y + r.height;

		r.x = m.d * id * x0 + -m.c * id * y0 + dx;
		r.y = m.a * id * y0 + -m.b * id * x0 + dy;
		r.width = m.d * id * x1 + -m.c * id * y1 + dx - r.x;
		r.height = m.a * id * y1 + -m.b * id * x1 + dy - r.y;
		
		if (r.width < 0) 
		{
			r.x += r.width;
			r.width *= -1;
		}
		
		if (r.height < 0)
		{
			r.y += r.height;
			r.height *= -1;
		}
		
	}
}