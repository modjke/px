package px;
import msignal.Signal.Signal0;
import pixi.core.display.Container;
import pixi.core.display.DisplayObject;
import pixi.core.math.shapes.Rectangle;
import pixi.core.renderers.SystemRenderer;
import pixi.core.utils.Utils;
import px.sound.PxSound;
import px.state.PxState;
import px.tools.pixi.ContainerTools;
import px.view.PxStage;
import tweenx909.TweenX;


@:allow(px.PxGame)
class Px 
{
	
	#if debug
	@:isVar
	public static var game(get, null):PxGame;
	static function get_game() 
	{
		if (game == null) throw "PxGame is not created yet";
		return game;
	}
	#else
	public static var game(default, null):PxGame;
	#end
	
	
	public static var width(get, null):Float;
	inline static function get_width() return game.width;
	
	public static var height(get, null):Float;
	inline static function get_height() return game.height;
	
	public static var viewport(get_viewport, null):Rectangle;
	inline static function get_viewport() return game.viewport;
	
	public static var mouse(get_mouse, null):PxMouse;
	inline static function get_mouse() return game.mouse;
	
	public static var stage(get_stage, null):PxStage;
	inline static function get_stage() return game.stage;
	
	public static var state(get_state, null):PxState;
	inline static function get_state() return game.state;
	
	public static var tweens(get_tweens, null):PxTweens;
	inline static function get_tweens() return game.tweens;
	
	public static var onExitSubState(get, null):Signal0;
	inline static function get_onExitSubState() return game.onExitSubState;
	
	public static var onExitState(get, null):Signal0;
	inline static function get_onExitState() return game.onExitState;
	
	public static var renderer(get, null):SystemRenderer;
	inline static function get_renderer() return game.renderer;
	
	public static var sound(get, null):PxSound;
	inline static function get_sound() return game.sound;
	
	public static var isMobile(get, null):Bool;
	inline static function get_isMobile() return Utils.isMobile.any;
	
	public static function switchState(state:PxState) 
		game.switchState(state);	
		
	
	static function setGame(game:PxGame)
	{
		Px.init();
		
		Px.game = game;
	}
	
	static var _initialized:Bool = false;
	
	static function init()
	{
		if (_initialized) return;
		_initialized = true;
		
		//do smth?
		
	}
	
}