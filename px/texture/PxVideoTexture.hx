package px.texture;
import js.html.VideoElement;
import pixi.core.textures.Texture;
import pixi.core.textures.VideoBaseTexture;

class PxVideoTexture extends Texture
{
	var videoElement:VideoElement;

	public function new(videoElement:VideoElement) 
	{
		this.videoElement = videoElement;

		var base = new VideoBaseTexture(videoElement);		
		base.autoPlay = false;
		super(base);	
	}

	override public function destroy(?destroyBase:Bool):Void 
	{		
		if (destroyBase) pause();
			
		super.destroy(destroyBase);		
	}
	
	public function pause()
	{
		
		videoElement.pause();
	}
	
	public function play(loop:Bool)
	{		
		videoElement.loop = loop;
		videoElement.play();
	}
}