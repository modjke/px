package px;
import haxe.io.Path;
import howler.Howl;
import js.html.ImageElement;
import msignal.Signal.Signal0;
import pixi.core.textures.BaseTexture;
import pixi.core.textures.Texture;
import pixi.core.utils.Utils;
import pixi.loaders.Loader;
import pixi.loaders.Resource;
import px.PxAssets.PxAtlas;
import px.loader.PxLoader;
import px.pending.Pending;
import px.psd2px.PxSpritesheet.PxAtlasJson;
import px.psd2px.PxSpritesheet.PxFrameJson;
import px.sound.PxSoundSource;
import px.utils.PxTextureUtils;

using Lambda;

abstract PxAtlas(Dynamic<Texture>) from Dynamic<Texture>
{	
	inline public function getFrame(name:String):Texture
	{
		var t:Texture = untyped this[name];
		if (t == null) throw 'Texture $name does not exist';
		return t;
	}
	
	inline public function getAll():Array<String>
	{
		return Reflect.fields(this);
	}
}

class PxAssets 
{

	public static var global(default, null):PxAssets = new PxAssets();
	
	@:allow(px.PxGame)
	public static var local(default, null):PxAssets = null;
	
	public var onComplete(default, null) = new Signal0();
	
	var loader:PxLoader;
	
	public function new() 
	{
		loader = new PxLoader();
		//pipe onComplete
		loader.onComplete.add(onComplete.dispatch);
	}
	
	public function resolveFontName(url:String):String
	{
		var r:Resource = getResource(url);
		if (r.bitmapFont == null || r.bitmapFont.font == null)
			throw 'resource.bitmapFont is null or resource.bitmapFont.font is null: $url';		
		return r.bitmapFont.font;
	}
	
	public function resolveFontSize(url:String):Int
	{
		var r:Resource = getResource(url);
		if (r.bitmapFont == null || r.bitmapFont.size == null) 
			throw 'resource.bitmapFont is null or resource.bitmapFont.size is null: $url';				
		return r.bitmapFont.size;
	}
	
	public function getAtlas(url:String):PxAtlas
	{
		var r = getResource(url);
		if (r.textures == null) 
			throw 'resource.textures is null: $url';
			
		return r.textures;
	}
	
	public function getSoundSource(url:String):PxSoundSource
	{
		var r = getResource(url);
		if (r.type != AUDIO)
			throw 'resource is not audio: $url';
			
		return r.data;
	}
	
	public function getTexture(url:String):Texture
	{
		var r:Resource = getResource(url);
		if (r.texture == null) throw 'resource.texture is null: $url';
		return r.texture;
	}
	
	public function getResource(url:String):Resource
	{
		return loader.getLoadedResourceByName(url);
	}
	
	public function load(paths:Dynamic, recursive = true):Pending<PxAssets>
	{
		var urls = getUrls(paths, recursive, []);		
		for (url in urls)					
			loader.add(url);				
				
		var p = Pending.resolvable();
		onComplete.addOnce(function () {
			p.resolve(this);
		});
		
		loader.load();
		
		return p;
	}
	

	public function loadTexture(url:String, disableRevision = true, loadType:LoadType = null):Pending<Null<Texture>>
	{
		var p = Pending.resolvable();
		//trace('add $url');
		loader.add(url, new PxLoaderOptions(disableRevision, IMAGE), function (resource) {			
			//trace('complete $url', resource != null, resource.texture != null);
			p.resolve(resource != null ? resource.texture : null);
		});
		loader.load();
		return p;
	}
	
	public function destroy()
	{	
		loader.destroy();			
		loader = null;
		
		Utils.clearTextureCache();
	}
	

	//TODO: make getUrls more robust
	function getUrls(paths:Dynamic, recursive:Bool, urls:Array<String>)
	{
		if ((paths is Array))
		{
			var array:Array<Dynamic> = paths;
			for (v in array)
				if ((v is String))
				{
					if (!urls.has(cast v)) urls.push(cast v);
				} else 
					if (recursive)
						getUrls(v, true, urls);
			
		} else {
			for (f in Reflect.fields(paths))
			{
				var v = Reflect.field(paths, f);
				if ((v is String))
				{
					if (!urls.has(cast v)) urls.push(cast v);
				} else {
					if (recursive)
						getUrls(v, true, urls);
				}
			}	
		}
		
		return urls;
	}
	
	
	
}