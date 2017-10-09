package px.loader;

import haxe.ds.StringMap;
import haxe.io.Path;
import js.Browser;
import js.html.Event;
import js.html.VideoElement;
import msignal.Signal.Signal0;
import pixi.core.textures.Texture;
import pixi.loaders.Loader;
import pixi.loaders.LoaderOptions;
import pixi.loaders.Resource;
import pixi.loaders.ResourceLoader;
import px.psd2px.PxSpritesheet.PxAtlasJson;
import px.psd2px.PxSpritesheet.PxFrameJson;
import px.sound.PxSoundSource;
import px.texture.PxVideoTexture;
import px.utils.PxTextureUtils;

using Lambda;

@:keep
abstract PxLoaderOptions(LoaderOptions) from LoaderOptions to LoaderOptions
{
	
	public static function shouldAppendRevision(metadata:LoaderMetadata):Bool
	{
		return metadata == null || untyped metadata.revisionDisabled != true;
	}

	public function new(revisionDisabled:Bool, loadType:LoadType = null)
	{
		var opts:LoaderOptions = { metadata: { }, loadType: cast loadType };
		
		untyped opts.metadata.revisionDisabled = revisionDisabled;
		this = opts;
	}
}

/**
 * Basicly PIXI.Loader but you can add new resources while loading
 * Also can't mess with name/url pairs
 * Also creates howls (howler.js) instead of Audio ojects
 * Also makes it easy to retrieve spritesheet textures (but this will be revorked)
 */
class PxLoader
{
	/*
	 * adds revision parameter to all urls
	 */
	public static var revision:String = null;
	
	public var onComplete(default, null) = new Signal0();

	var loader:Loader = new Loader();
	var resources:StringMap<PendingResource> = new StringMap();
	var addLater:Array<PendingResource> = [];	
	
	
	
	//there is a bug/feature inside pixi's loader: if load() is called and _queue is empty 
	//loader will never fire complete event and loader.loading will always be true
	//to avoid that we call load() only if _queue is not empty
	var hasSomethingToLoad = false;
	
	public function new() 
	{
		loader.pre(_pxPreMiddleware);
		loader.use(_pxAfterMiddleware);		
		loader.on("complete", _processPendings);
	}
	

	public function load()
	{
		//execute loaded callbacks
		for (r in resources)
			if (r.loaded)
				r.executeCallbacks();

		trace("!", loader.loading, hasSomethingToLoad);
		if (!loader.loading) 
		{
			if (hasSomethingToLoad)
				loader.load();
			else 
				onComplete.dispatch();
		}
		
		
	}
	
	function _processPendings(?event)
	{
		trace('pendings on complete: ${addLater.length}');
		
		var shouldLoad = addLater.length > 0;
		if (shouldLoad)
		{
			for (p in addLater)
				loader.add(p.url, p.url, p.options, p.onResourceLoaded);
				
			addLater.splice(0, addLater.length);
			
			loader.load();	
		} else {
			
			hasSomethingToLoad = false;
			onComplete.dispatch();		
		}
	}
	
	/**
	 * TODO: rework this :) not the most reliable way
	 */
	public function destroy()
	{
		for (pr in resources)
		{			
			var r = pr.resource;
			if (r == null)
				continue;
				
			if (r.texture != null)
			{											
				r.texture.destroy(true);				
			} else if (r.spritesheet != null)
			{				
				r.spritesheet.destroy(true);
			} else if ((r.data is PxSoundSource)) {
				var sndSource:PxSoundSource = r.data;
				sndSource.destroy();
			} else {
				//TODO: implement destroy for this kind of resource OR load it globally
				trace("Don't know how to destroy that kind of the resource");
				trace(pr);
			}
		}
				
		onComplete.removeAll();
		
		loader.off("complete", _processPendings);
		loader.reset();
		
		resources = null;
		addLater = null;
		onComplete = null;
		loader = null;
	}
	
	public function getLoadedResourceByName(url:String):Resource
	{
		var p = resources.get(url);
		if (p == null) throw 'Resource with $url not found';
		if (!p.loaded) throw 'Resource with $url is still loading';
		//if (p.error != null) throw 'Resource with $url loaded with error: ${p.error}';
		return p.resource;
	}	
	
	public function add(url:String, ?options:PxLoaderOptions, ?callback:Resource->Void) 
	{	
		trace('add $url');
		var p = resources.get(url);
		
		if (p != null) {	
			trace('adding callback');
			p.addCallback(callback);			
		} else {			
			trace('creating new');
			p = new PendingResource(url, options, callback);			
			resources.set(url, p);
			
			trace('is loading? ${ loader.loading }');
						
			if (loader.loading)
				addLater.push(p);
			else 
			{
				hasSomethingToLoad = true;			
				
				loader.add(p.url, p.url, p.options, p.onResourceLoaded);
			}
		}		
	}
	
	
	
	@:keep
	static function _pxPreMiddleware(r:Resource, next:Void->Void):Void
	{
		var extensions = r.extension.split(",");

		var shouldAppendRevision = PxLoaderOptions.shouldAppendRevision(r.metadata);
		
		inline function rev(url:String) return shouldAppendRevision ? appendRevision(url) : url;
		
		switch (getExtensionType(extensions))
		{
			case AUDIO:
				var baseUrl = Path.withoutExtension(r.url);
				
				var urls = extensions.map(function (e) return rev('$baseUrl.$e'));
		
				r.loadType = AUDIO;			
				r.metadata.skipSource = true;
				r.metadata.loadElement = new PxSoundSource(urls);
				
			case VIDEO:
				r.url = rev(r.url);
				
				//adding revision confuses the ResourceLoader
				//so we 'fake' a video element with a loadType
				//also playsiniline attr for IOS
 				r.loadType = VIDEO;				
				r.metadata.skipSource = true;
				
				var video = Browser.document.createVideoElement();
				video.setAttribute("playsinline", "");
				video.src = r.url;
				r.metadata.loadElement = video;
				
				
			case OTHER:
				r.url = rev(r.url);
			
		}
		
		
		
		next();
	}
	
	
	@:keep
	static function _pxAfterMiddleware(r:Resource, next:Void->Void):Void
	{
		if (r.spritesheet != null)
		{
			var atlas:PxAtlasJson = r.spritesheet.data;
			for (name in Reflect.fields(atlas.frames))
			{
				var f:PxFrameJson = Reflect.field(atlas.frames, name);
				
				if (f.pivot != null || f.anchor != null)
				{
					var t:Texture = Reflect.field(r.spritesheet.textures, name);
					if (t == null) throw 'Can\'t find a texture from a spritesheet: $name';
						
					if (f.pivot != null)  PxTextureUtils.setDefaultPivot(t, f.pivot.x, f.pivot.y);
					if (f.anchor != null) PxTextureUtils.setDefaultAnchor(t, f.anchor.x, f.anchor.y);					
				}
				
			}
		}
		
		if (r.type == VIDEO)
			r.texture = new PxVideoTexture((r.data:VideoElement));		
			
		next();
	}
	
	static function appendRevision(url:String):String
	{
		if (revision != null)
		{
			var idx = url.lastIndexOf("?");
			if (idx == -1)
				return '$url?$revision';
			else 
			if (idx == (url.length - 1))
				return '$url$revision';
			else 
				return '$url&revision';
		} else 
			return url;
		
	}
	
	static function getExtensionType(extensions:Array<String>)
	{
		if (isThisAudioExtensions(extensions))
			return AUDIO;
		else 
		if (isThisVideoExtensions(extensions))
			return VIDEO;
		else 
			return OTHER;
	}
	
	static var audioExtensions = ["mp3", "mpeg", "opus", "ogg", "oga", "wav", "aac", "caf", "m4a", "weba",  "dolby", "flac"];
	static function isThisAudioExtensions(exts:Array<String>)
	{
		for (e in exts) 
			if (audioExtensions.indexOf(e) == -1)
				return false;
				
		return true;
	}
	
	static var videoExtensions = ["webm", "mp4", "ogv"];
	static function isThisVideoExtensions(exts:Array<String>)
	{
		for (e in exts) 
			if (videoExtensions.indexOf(e) == -1)
				return false;
				
		return true;
	}
}

enum ExtensionType 
{
	AUDIO; VIDEO; OTHER;
}

class PendingResource
{
	public var url(default, null):String = null;
	public var options(default, null):PxLoaderOptions = null;
	public var resource(default, null):Resource = null;
	public var loaded(default, null):Bool = false;
	
	public var error(default, null):Dynamic = null;
	
	var callbacks:Array<Resource->Void> = [];
	
	public function new(url:String, ?options:PxLoaderOptions, ?callback:Resource->Void )
	{
		this.url = url;
		this.options = options;
		
		if (callback != null) 
			callbacks.push(callback);
	}
	
	public function addCallback(?callback:Resource-> Void)
	{
		if (callback != null)		
			callbacks.push(callback);
	}
	
	public function executeCallbacks()
	{
		if (!loaded) throw "Can't executeCallbacks before loaded";

		if (callbacks.length > 0)
		{
			for (c in callbacks) c(resource);
			callbacks.splice(0, callbacks.length);	
		}		
	}
	
	public function onResourceLoaded(r:Resource)
	{
		if (loaded) throw "Can't set resource twice";
		
		var noErrors = r.error == null;
		this.error = r.error;
		this.loaded = true;
		this.resource = noErrors ? r : null;
		
		executeCallbacks();
	}
}