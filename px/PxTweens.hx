package px;
import px.state.PxSubState;
import tweenx909.TweenListX;
import tweenx909.TweenX;

class PxTweens
{

	public var global(default, null):TweenListX;
	public var state(default, null):TweenListX;
	public var subState(default, null):TweenListX;

	//TODO: consider storing lists inside states?
	
	@:allow(px.PxGame)
	private function new()
	{		
		global = TweenX.defaultList;
		state = new TweenListX();
		subState = new TweenListX();
		
		TweenX.lists.push(state);
		TweenX.lists.push(subState);
		
		TweenX.defaultList = state;		
		TweenX.updateMode = MANUAL;		

		Px.onExitSubState.add(function () TweenX.stopListImmidiate(subState) );		
		Px.onExitState.add(function () TweenX.stopListImmidiate(state) );
	}
	
	
	public function update()
	{	
		TweenX.manualUpdate(PxTime.elapsed);		
	}
	
}