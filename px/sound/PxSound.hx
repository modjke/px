package px.sound;
import howler.Howl;
import howler.Howler;
import js.Browser;
import px.sound.PxSoundSource.PxHowl;


class PxSound
{

	public function new() 
	{
		
	}
	
	public var mute(default, set):Bool = false;
	function set_mute(v:Bool):Bool
	{
		Howler.mute(v);
		return mute = v;
	}
	
	public var vibrateEnabled:Bool = true;
	
	public function play(url:String):PxHowl
	{
		return getLocalOrGlobal(url).play();		
	}
	
	public function stop(url:String)
	{
		getLocalOrGlobal(url).stop();		
	}
	
	
	public function vibrate(seconds:Float)
	{
		if (vibrateEnabled)
		{
			var ms = Std.int(seconds * 1000);
			try {
				Browser.navigator.vibrate(ms);
			} catch (ignore:Dynamic) {}			
		}
	}
	
	public
	
	inline function getLocalOrGlobal(url:String):PxSoundSource
	{		
		var soundSource:PxSoundSource = null;		
		try {
			soundSource = PxAssets.local.getSoundSource(url);
		} catch (any:Dynamic) {
			try {
				soundSource = PxAssets.global.getSoundSource(url);				
			} catch (any:Dynamic) {}
		}
		
		if (soundSource == null)
			throw 'Unable to find an audio source for $url';
			
		return soundSource;
	}
}