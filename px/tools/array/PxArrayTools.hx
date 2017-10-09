package px.tools.array;

class PxArrayTools 
{

	/**
	 * Reverses array
	 */
	public static function reversed<T>(array:Array<T>):Array<T>
	{
		array.reverse();
		return array;
	}
	
	public static function concated<T>(a:Array<T>, b:Array<T>):Array<T>
	{
		return a.concat(b);
	}
	
}