package px.utils;
import js.Browser;
import js.html.CanvasElement;
import pixi.core.Pixi.ScaleModes;
import pixi.core.display.Container;
import pixi.core.display.DisplayObject;
import pixi.core.math.shapes.Rectangle;
import pixi.core.sprites.Sprite;
import pixi.core.textures.RenderTexture;

/**
 * Fix this shit
 */
class PxScreenshot
{

	/**
	 * Makes a screenshot and returns base64 data
	 * Temporarely sets targets x/y props and renderer width/height
	 * Takes scale of target into account!
	 * Also textures should be loaded :)
	 * @param	target
	 * @param	area
	 * @return
	 */
	public static function toImageData(target:DisplayObject, area:Rectangle, ?resolution:Float = 1.0, ?type:String, ?encoderOptions:Dynamic):String
	{
		var renderTexture = toRenderTexture(target, area, resolution);
		
		var oldW = Px.renderer.width / Px.renderer.resolution;
		var oldH = Px.renderer.height / Px.renderer.resolution;
		
		Px.renderer.resize(area.width / Px.renderer.resolution, area.height / Px.renderer.resolution);
		var imageData:String = untyped Px.renderer.extract.base64(renderTexture);
		Px.renderer.resize(oldW, oldH);

		return imageData;		
	}
	
	/**
	 * Makes a render texture and returns it
	 * Temporarely sets targets x/y props 
	 * Takes scale of target into account!
	 * Also textures should be loaded :)
	 * @param	target
	 * @param	area
	 * @return
	 */
	public static function toRenderTexture(target:DisplayObject, area:Rectangle, ?resolution:Float = 1.0):RenderTexture
	{
		target.x -= area.x;
		target.y -= area.y;
		
		var renderTexture = RenderTexture.create(area.width, area.height, ScaleModes.LINEAR, resolution);
		Px.renderer.render(target, renderTexture, true);

		target.x += area.x;
		target.y += area.y;
		
		return renderTexture;	
	}
	
}