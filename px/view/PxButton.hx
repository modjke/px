package px.view;

import sandoz.kk.Paths;
import js.html.EventTarget;
import msignal.Signal.Signal0;
import pixi.core.display.DisplayObject.DestroyOptions;
import pixi.core.math.Point;
import pixi.core.sprites.Sprite;
import pixi.core.textures.Texture;
import haxe.extern.EitherType;
import pixi.interaction.InteractionEvent;
import tweenx909.TweenX;


class PxButton extends Sprite 
{
	inline static var DOWN_OFF = 2.0;	
	
	public var onOver(default, null) = new Signal0();
	public var onOut(default, null) = new Signal0();
	
	public var disabled(default, set):Bool = false;
	function set_disabled(v:Bool):Bool
	{
		if (v)
		{
			applyDown(false);
			applyOver(false);
			this.interactive = false;
			this.buttonMode = false;
		} else {
			this.interactive = true;
			this.buttonMode = true;
		}
		
		return disabled = v;
	}
	
	public var checkable:Bool = false;
	
	public var checked(default, set):Bool = false;
	function set_checked(v:Bool):Bool
	{		
		applyOver(v);
			
		return checked = v;
	}

	var normal:Texture;
	var over:Texture;
	var overOffset:Point;
	
	var __over:Bool = false;	
	var __down:Bool = false;
	
	function applyOver(v:Bool)
	{
		if (__over == v) return;
		__over = v;
		
		texture = __over ? over : normal;
		pivot.x += overOffset.x * (__over ? 1 : -1);
		pivot.y += overOffset.y * (__over ? 1 : -1);
		
		if (__over)
			onOver.dispatch();
		else
			onOut.dispatch();
	}
	
	function applyDown(v:Bool)
	{
		if (__down == v) return;
		__down = v;
		
		this.x += DOWN_OFF * (__down ? 1 : -1);
		this.y += DOWN_OFF * (__down ? 1 : -1);
				
	}
	
	/**
	 * 
	 * @param	action action, if null clears action
	 * @param	once = false
	 */
	var _action:PxButton->Void;
	var _once:Bool = false;
	public function setAction(action:PxButton->Void, once = false)
	{		
		_action = action;
		_once = once;
		return this;
	}
	
	function _onClick(event:InteractionEvent)
	{
		if (_action != null)
		{
			_action(this);
			if (_once) 
				_action = null;			
		}		
	}
	
	public function new(normal:Texture, ?over:Texture, ?overOffset:Point) 
	{
		super(normal);
		
		this.normal = normal;
		this.over = over != null ? over : normal;
		this.overOffset = overOffset != null ? overOffset : new Point(0, 0);
		
		this.interactive = true;
		this.buttonMode = true;
		
		this.on("mouseover", function (_) {
			if (checkable)
			{
				if (!checked) 
					applyOver(true);					
			} else
				applyOver(true);		
		});
		this.on("mouseout", function (_) {
			if (checkable)
			{
				if (!checked) 
					applyOver(false);
			} else 
				applyOver(false);
		});
		
		
		this.on("mousedown", _onDown);
		this.on("mouseup", _onUp);
		this.on("mouseout", _onUp);
		
		this.on("touchstart", _onDown);
		this.on("touchend", _onUp);		
		
		this.click = this.tap = _onClick;
	}
	
	
	
	
	
	override public function destroy(?options:EitherType<Bool, DestroyOptions>):Void 
	{
		super.destroy(options);
		
		onOver.removeAll();
		onOut.removeAll();
		normal = null;
		over = null;
		overOffset = null;
		TweenX.killTweensOf(_autoOnUp);
	}	
	
	function _onDown(e:InteractionEvent) 
	{
		applyOver(true);
		applyDown(true);		
		
		//if happend on mobile
		if (e.type == "touchstart")
		{
			TweenX.killTweensOf(_autoOnUp);			
			TweenX.func(_autoOnUp, 1.0);
		}
			
		
		
	}
	
	function _autoOnUp() {
		if (!(checkable && checked))
		{			
			applyOver(false);
			applyDown(false);
		}
	}
	
	function _onUp(e:InteractionEvent) 
	{	
		applyDown(false);				
		
		if (e.type == "touchend")
		{
			TweenX.killTweensOf(_autoOnUp);		
			applyOver(false);
		}
	}
	
	
	public function swapStates()
	{
		var temp = normal;
		normal = over;
		over = temp;
		temp = null;
		texture = normal;
	}
}