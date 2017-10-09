package px.state;

class PxOutState extends PxState 
{

	@:noCompletion
	var __out:Bool = false;
	
	public function new() 
	{
		super();
	}


	public function out(newState:PxState)
	{
		if (__out) 		
			return;		
		
		__out = true;
		
		animateOut(function ()
		{
			Px.switchState(newState);
		});
	}
	
	function animateOut(onComplete:Void->Void)
	{
		onComplete();
	}
}