package px.state;
import px.PxAssets;
import px.state.PxSubState;
import tweenx909.TweenListX;
import tweenx909.TweenX;


//TODO: should not be a decendant of PxState

@:allow(px.state.PxState)
class PxSubState extends PxState 
{
	public function new() 
	{
		super();
		
	}
	
	override public function create() 
	{
		super.create();	
	}
	
	override public function openSubState(subState:PxSubState) 
	{
		throw "SubStates can't have a child SubStates";
	}
	
	override public function closeSubState() 
	{
	
	}
	
	public function closeSelf()
	{
		if (Px.state.subState == this)
			Px.state.closeSubState()
		else
			throw "Current subState is not this!";
	}
	
	override public function update() 
	{
		super.update();
	}
	
	override public function destroy() 
	{		
		super.destroy();
	}
	
}