package px.tools.tween;
import tweenx909.TweenListX;
import tweenx909.TweenX;

class PxTweenTools 
{

	public inline static function global(t:TweenX):TweenX
	{
		return t.list(Px.tweens.global);
	}
	
	public inline static function sub(t:TweenX):TweenX
	{	
		return t.list(Px.tweens.subState);
	}
	

	
	
	
}