package px.resize;
import pixi.core.display.Container;


class ScaleToBiggerSideScaleMode extends ScaleMode 
{
	var szWidth:Float;
	var szHeight:Float;

	public function new(szWidth:Float, szHeight:Float) 
	{
		super();
		
		this.szWidth = szWidth;
		this.szHeight = szHeight;
	}
	
	override public function resize(stage:Container, rendererWidth:Float, rendererHeight:Float)
	{		
		var scale = Math.min(rendererWidth / szWidth, rendererHeight / szHeight);				
		var ssWidth = Px.width * scale;
		var ssHeight = Px.height * scale;
		
		stage.x = (rendererWidth - ssWidth) * .5;
		stage.y = (rendererHeight - ssHeight) * .5;
		stage.scale.set(scale, scale);		
	}
}