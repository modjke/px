package px;
import pixi.core.display.Container;
import pixi.core.display.DisplayObject;
import pixi.core.math.Point;
import pixi.interaction.InteractionData;
import pixi.interaction.InteractionEvent;

@:allow(px.PxGame)
class PxMouse 
{
	public var justPressed(default, null):Bool = false;
	
	public var justReleased(default, null):Bool = false;
	
	public var pressed(default, null):Bool = false;
	
	public var x(get, never):Float;
	inline function get_x() return position.x;
	
	public var y(get, never):Float;
	inline function get_y() return position.y;
	
	public var prevx(get, never):Float;
	inline function get_prevx() return position.x - delta.x;
	
	public var prevy(get, never):Float;
	inline function get_prevy() return position.y - delta.y;
	
	public var delta(default, null) = new Point(0, 0);
	
	public function getLocal(displayObject:DisplayObject, ?point:Point):Point
	{
		return data.getLocalPosition(displayObject, point);
	}
	
	var position = new Point(0, 0);
	var eventPosition = new Point(0, 0);
	var stage:Container = null;
	var data:InteractionData = new InteractionData();

	function new(stage:Container)
	{
		this.stage = stage;
	
		stage.interactive = true;
		stage.on("mousedown", downHandler);
		stage.on("mouseup", upHandler);
		stage.on("mousemove", moveHandler);
		stage.on("touchstart", downHandler);
		stage.on("touchend", upHandler);
		stage.on("touchmove", moveHandler);
	}	
	
	function update()
	{
		delta.set(
			eventPosition.x - position.x,
			eventPosition.y - position.y
		);		
		
		position.copy(eventPosition);
	}

	function exitFrame()
	{
		justPressed = false;
		justReleased = false;
		
		delta.x = 0;
		delta.y = 0;
	}
	
	function upHandler(event:InteractionEvent)
	{	
		this.data = event.data;
		event.data.getLocalPosition(stage, eventPosition);
		
		pressed = false;		
		justReleased = true;
	}
	
	function downHandler(event:InteractionEvent)
	{
		this.data = event.data;
		event.data.getLocalPosition(stage, eventPosition);
		position.copy(eventPosition);
		
		pressed = true;
		justPressed = true;		
	}
	
	
	function moveHandler(event:InteractionEvent)
	{
		this.data = event.data;
		event.data.getLocalPosition(stage, eventPosition);		
	}
}