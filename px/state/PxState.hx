package px.state;
import msignal.Signal.Signal0;
import pixi.core.display.DisplayObject;
import px.PxAssets;
import px.tools.pixi.ContainerTools;
import px.view.PxContainer;


class PxState
{		
	public var localAssets(default, null):PxAssets;
	
	public var view(default, null):PxContainer;
	
	public var subState(default, null):PxSubState = null;
	
	var destroyed = false;
	
	private var _onExitSubState:Signal0 = null;
	public var onExitSubState(get, null):Signal0;
	function get_onExitSubState() {
		if (_onExitSubState == null) _onExitSubState = new Signal0();
		return _onExitSubState;
	}
	
	var persistUpdate(default, set_persistUpdate):Bool = false;
	inline function set_persistUpdate(v:Bool)
	{
		if (hasSubState) throw "Can't modify persistUpdate while subState is opened";		
		return persistUpdate = v;
	}
	
	public var hasSubState(get, null):Bool;
	inline function get_hasSubState() return subState != null;
	
	public function openSubState(subState:PxSubState)
	{
		
		if (this.subState != null)
			closeSubState();
			
		this.subState = subState;		
		this.subState.create();
		
		view.interactive = 
		view.interactiveChildren = false;
		
		//TODO: not the best decision???
		//responsibility of adding subStates view should be on the other component
		ContainerTools.insertChildOnTopOf(Px.stage, subState.view, view);
	}
	
	public function closeSubState()
	{
		if (subState != null)
		{			
			view.interactive = 
			view.interactiveChildren = true;		

			this.subState.destroy();
			this.subState = null;			
			
			onExitSubState.dispatch();
		}
		
	}
	
	public function new() 
	{		
		localAssets = new PxAssets();
		view = new PxContainer();			
	}
	
	public function create()
	{		
		
	}
	
	@:noCompletion
	@:allow(px.PxGame)
	function _update()
	{
		if (subState != null)
		{
			subState.update();
			if (persistUpdate)
				update();
		} else 
			update();
	}
	
	public function update()
	{
		
	}
	
	public function destroy()
	{
		destroyed = true;
		
		closeSubState();
		
		if (_onExitSubState != null)
			_onExitSubState.removeAll();
			
		view.destroy({ children: true });		
		
		if (localAssets != null)		
			localAssets.destroy();			
	}
	
	public function addChild<T:DisplayObject>(child:T):T
	{
		return view.addChild(child);
	}
	
}