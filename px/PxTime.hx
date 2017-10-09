package px;


@:allow(px.PxGame)
class PxTime 
{

	/**
	 * Seconds on last frame
	 */
	public static var elapsed(default, null):Float = 0.0;
	
	/**
	 * Seconds total
	 */
	public static var elapsedTotal(default, null):Float = 0.0;
	
	/**
	 * Frame time multiplier (1.0 if elapsedFrame is exactly 1/60 second)
	 */
	public static var frame(default, null):Float = 1.0;
	
	
	/**
	 * Current fps
	 */
	public static var fps(default, null):Float = 60.0;
	
	/**
	 * Called by PxGame	 
	 */
	static function update(elapsedMs:Float)
	{
		PxTime.elapsed = elapsedMs / 1000.0;
		PxTime.elapsedTotal += PxTime.elapsed;		
		PxTime.frame = PxTime.elapsed / ( 1.0 / 60.0 );
		PxTime.fps = 1000.0 / elapsedMs;
	}
	
	private function new() {}
	
}