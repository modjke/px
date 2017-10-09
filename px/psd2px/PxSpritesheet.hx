package px.psd2px;
import haxe.Json;
#if neko
import sys.io.File;
#end
import haxe.io.Path;

using Lambda;

class PxSpritesheet 
{

	#if neko
	/**
	 * Adds default pivots / anchors to a spritesheet json
	 * @param	filename
	 * @param	textures
	 */
	public static function pushAdditionalTextureInfo(filename:String, textures:Array<PsdEntry>)
	{
		var a:PxAtlasJson = Json.parse(File.getContent(filename));
		for (name in Reflect.fields(a.frames))
		{
			var texture = textures.find(function (t) return t.image == name);
			if (texture == null) continue;
			
			if (texture.type != TEXTURE) throw "Not a texture!";
			
			var frame:PxFrameJson = Reflect.field(a.frames, name);
			frame.pivot = texture.pivot;
			frame.anchor = texture.anchor;
		}
		
		File.saveContent(filename, Json.stringify(a, null, " "));
	}
	
	public static function retrievePngsPaths(jsonPath:String):Array<String>
	{
		var a:PxAtlasJson = Json.parse(File.getContent(jsonPath));		
		var dir = Path.directory(jsonPath);
		return [Path.join([dir, a.meta.image])];
	}
	
	#end
}

typedef PxAtlasJson = {
	frames: Dynamic<PxFrameJson>,
	meta: {
		image: String,
		scale: Float,
		size: { w:Float, h:Float }
	}
}

typedef PxFrameJson = {
	frame: { x:Float, y:Float, w:Float, h:Float },
	spriteSourceSize: { x:Float, y:Float, w:Float, h:Float },
	sourceSize: { w:Float, h:Float },
	
	//added by pushAdditionalTextureInfo
	?pivot: { x:Float, y:Float },
	?anchor: { x:Float, y:Float },
}