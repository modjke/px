package px.resize;
import pixi.core.display.Container;

class FillScaleMode extends ScaleMode 
{

	public function new() 
	{
		super();
		
	}
	
	override public function resize(stage:Container, rendererWidth:Float, rendererHeight:Float) 
	{
		var scale = Math.max(rendererWidth / Px.width, rendererHeight / Px.height);				
		var ssWidth = Px.width * scale;
		var ssHeight = Px.height * scale;
		
		stage.x = (rendererWidth - ssWidth) * .5;
		stage.y = (rendererHeight - ssHeight) * .5;
		stage.scale.set(scale, scale);		
	}
	
}