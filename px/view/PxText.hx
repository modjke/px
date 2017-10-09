package px.view;

import pixi.core.display.DisplayObject.DestroyOptions;
import pixi.core.graphics.Graphics;
import pixi.extras.BitmapText;
import pixi.extras.BitmapText.BitmapTextStyle;
import haxe.extern.EitherType;

//TODO: support local/global assets
class PxText extends BitmapText 
{
	
	var underline:Graphics;

	public function new(text:String, font:String, ?size:Float = null, ?align:BitmapTextAlign = LEFT, ?tint:Int = null) 
	{
		super(text, {
			font: {
				name: PxAssets.global.resolveFontName(font),
				size: size != null ? size : PxAssets.global.resolveFontSize(font)
			},
			align: align,
			tint: tint
		});
		
	}

	
	public function setUnderline(thikness:Float, color = 0xFFFFFF)
	{
		if (underline == null)
		{
			underline = new Graphics();
			addChild(underline);
		}
		
		underline.clear();
		if (thikness > 0.0)
		{
			underline.beginFill(color);
			underline.drawRect(0, 0, this.textWidth, thikness);
			underline.endFill();
		
			underline.y = this.textHeight;
		}
		
		return this;
	}

}