package px.sound;
import haxe.ds.StringMap;
import howler.Howl;
import js.Browser;
import js.html.ErrorEvent;
import js.html.Event;
import haxe.Constraints.IMap;
import js.html.JsCompat;

@:allow(px.sound.PxSoundSource)
class PxHowl
{
	var howl:Howl;
	var id:Int;
	
	public var volume(get, set):Float;
	function get_volume() return howl.volume(id);
	function set_volume(v:Float) {
		howl.volume(v, id);
		return v;
	}
	
	public function withVolume(volume:Float)
	{
		this.volume = volume;
		return this;
	}
		
	private function new(howl:Howl)
	{
		this.howl = howl;
		this.id = howl.play();
	}
	
	public function play()
	{
		howl.play(id);
		
		return this;
	}
	
	public function loop(loop:Bool)
	{
		howl.loop(loop, id);
		
		return this;
	}
	
	public function stop()
	{
		howl.stop(id);
		
		return this;
	}	
}

@:keep
class PxSoundSource extends FakeEmitter
{
	var src:Array<String>;
	var howl:Howl;
	
	public function new(src:Array<String>) 
	{
		super();
		
		this.src = src;		
	}
	
	public function load()
	{
		howl = new Howl({
			src: src,
			autoplay: false,
			onloaderror: function () 
			{
				var event:ErrorEvent;
				try {
					event = new ErrorEvent("error");
				} catch (any:Dynamic)
				{
					//IE polyfill
					event = cast Browser.document.createEvent("ErrorEvent");
					event.initEvent("error", false, false);
				}
				dispatchEvent(event);
			},
			onload: function ()
			{
				var event:Event;
				try {
					event = new Event("load");
				} catch (any:Dynamic)
				{
					
					//IE polyfill
					event = cast Browser.document.createEvent("Event");
					event.initEvent("load", false, false);
				}
				
				dispatchEvent(event);
				
			}
		});
	}
	
	public function play():PxHowl
	{
		return new PxHowl(howl);
	}
	
	public function stop()
	{
		howl.stop();
	}

	override public function destroy()
	{
		super.destroy();
		
		howl.unload();
	}
}


@:keep
class FakeEmitter
{
	var listenersMap:IMap<String, Array<Event->Void>> = new StringMap();
	
	public function new()
	{
		
	}
	
	public function addEventListener(event:String, listener:Event->Void)
	{
		//trace("addEventListener", event);
		var listeners = listenersMap.get(event);
		if (listeners == null)
		{
			listeners = [];
			listenersMap.set(event, listeners);
		}
		
		if (listeners.indexOf(listener) == -1)
			listeners.push(listener);
	}
	
	public function removeEventListener(event:String, listener:Event->Void)
	{
		//trace("removeEventListener", event);
		var listeners = listenersMap.get(event);
		if (listeners != null && listeners.indexOf(listener) > -1)
			listeners.remove(listener);		
	}
	
	public function dispatchEvent(event:Event)
	{
		//trace("dispatchEvent", event.type);
		var listeners = listenersMap.get(event.type);
		if (listeners != null)
			for (l in listeners)
				l(event);
	}
	
	public function destroy()
	{
		listenersMap = null;
	}
}