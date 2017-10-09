package px;
import js.Browser;
import js.html.CanvasElement;
import msignal.Signal.Signal0;
import pixi.core.display.Container;
import pixi.core.display.Transform;
import pixi.core.math.shapes.Rectangle;
import pixi.core.renderers.Detector;
import pixi.core.renderers.SystemRenderer;
import pixi.core.ticker.Ticker;
import px.resize.ScaleMode;
import px.sound.PxSound;
import px.state.PxState;
import px.tools.pixi.ContainerTools;
import px.view.PxStage;

enum MobileOrientation {
	HORIZONTAL;
	VERTICAL;
}

typedef PxGameSettings = {
	width:Int,
	height:Int,
	scaleMode:ScaleMode,
	background:Int,
	canvas:CanvasElement,
	?forceOrientation: MobileOrientation,
	?initialState:PxState
}

class PxGame
{

	public var onResize(default, never):Signal0 = new Signal0();
	
	//TODO: rename onExit to onDestroy? cause this is what it is
	public var onExitState(default, never):Signal0 = new Signal0();
	
	//TODO: rename onExit to onDestory? cause this is what it is
	public var onExitSubState(default, never):Signal0 = new Signal0();
	
	public var width(default, null):Float;
	
	public var height(default, null):Float;
	
	public var mouse(default, null):PxMouse;
		
	public var viewport(default, never):Rectangle = new Rectangle(0, 0, 0, 0);	
	
	public var foreground(default, never):Container = new Container();
	
	public var stage(default, never):PxStage = new PxStage();
	
	public var background(default, never):Container = new Container();
		
	public var state(default, null):PxState = null;

	public var scaleMode(default, null):ScaleMode = null;
	
	public var tweens(default, null):PxTweens = null;
	
	public var renderer(default, null):SystemRenderer = null;
	
	public var sound(default, null):PxSound = null;
	
	
	var ticker:Ticker = Ticker.shared;

	var forceOrientation:MobileOrientation;
	var root:Container;
	var pendingState:PxState = null;
	
	var resolution:Float;

	public function new(settings:PxGameSettings)
	{						
		Px.setGame(this);
		
		this.width = settings.width;
		this.height = settings.height;
		this.scaleMode = settings.scaleMode;
		this.forceOrientation = settings.forceOrientation;
		this.tweens = new PxTweens();
		
		this.resolution = Browser.window.devicePixelRatio;
		if (this.resolution == null) this.resolution = 1.0;
		
		//width/height passed here does not really matter
		//since processResize() will resize renderer accordingly
		renderer = Detector.autoDetectRenderer( 
		{
			width: Std.int(width),
			height: Std.int(height),
			resolution: resolution,
			view: settings.canvas,
			autoResize: false,
			backgroundColor: settings.background,		
			antialias: true,
			
		}, false);
			
		//create stuff
		root = new Container();	
		root.addChild(stage);
		stage.addChild(background);
		stage.addChild(foreground);		
		mouse = new PxMouse(stage);
		sound = new PxSound();

		//add listeners		
		ticker.add(update);

		//first time resize
		resize();
		
		//initial state
		if (settings.initialState != null)
			switchState(settings.initialState);
	}
	
	public function resize(?forceWidth:Float, ?forceHeight:Float)
	{ 		
		var bounds = renderer.view.getBoundingClientRect();
		var width = forceWidth != null ? forceWidth : bounds.width;
		var height = forceHeight != null ? forceHeight : bounds.height;
		
		renderer.resize(width, height);
		
		var orientedWidth:Float = renderer.width;
		var orientedHeight:Float = renderer.height;
		var rotated = false;
		if (forceOrientation != null)
		{
			switch (forceOrientation)
			{
				case HORIZONTAL:
					if (orientedHeight > orientedWidth)
					{
						orientedWidth = renderer.height;
						orientedHeight = renderer.width;
						rotated = true;
					}
				case VERTICAL:
					if (orientedWidth > orientedHeight)
					{
						orientedWidth = renderer.height;
						orientedHeight = renderer.width;
						rotated = true;
					}
			}
		}
		
		var rendererWidth = orientedWidth / resolution;
		var rendererHeight = orientedHeight / resolution;
						
		scaleMode.resize(stage, rendererWidth, rendererHeight);
				
		viewport.x = -stage.x / stage.scale.x;
		viewport.y = -stage.y / stage.scale.y;
		viewport.width = rendererWidth / stage.scale.x;
		viewport.height = rendererHeight / stage.scale.y;
		
		
		stage.rotation = rotated ? Math.PI * .5 : 0;
		if (rotated)
		{
			var x = stage.x;
			stage.x = stage.y + Px.height * stage.scale.y;
			stage.y = x;
		}
				
		onResize.dispatch();
	}
	
	
	public function switchState(state:PxState)
	{				
		pendingState = state;				
	}
	
	function update()
	{		
		PxTime.update(ticker.elapsedMS);
		
		mouse.update();
		
		tweens.update();
		
		
		if (pendingState != state)
		{
			while (pendingState != state)
			{
				var nextState = pendingState;
				
				if (state != null)
				{											 					
					state.destroy();	//also removes it's view from subStage
					state = null;					
					
					PxAssets.local = null;										
					
					onExitState.dispatch();					
				}

				state = nextState;		
				
				PxAssets.local = state.localAssets;
				
				//pipe onExitSubState
				state.onExitSubState.add(onExitSubState.dispatch);
				
				ContainerTools.insertChildUnder(stage, state.view, foreground);			
				
				state.create();	
			}
		}
		
		if (state != null)			
			state._update();			
			

		renderer.render(root);
		
		mouse.exitFrame();
	}


}