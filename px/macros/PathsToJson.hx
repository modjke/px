package px.macros;

import haxe.io.Path;
#if macro
import sys.FileSystem;
#end
import haxe.macro.Expr;
import haxe.macro.Context;

using StringTools;

class PathsToJson 
{
	public static macro function parse(sourceDir:String, runtimeDir:String, extensions:Array<String>):ExprOf<Dynamic>
	{
		sourceDir = Context.resolvePath(sourceDir);	
		
		var json:Dynamic<String> = _collect(sourceDir, runtimeDir, extensions);

		return macro $v{json};
	}
	
	#if macro
	static function _collect(sourceDir:String, runtimeDir:String, extensions:Array<String>):Dynamic
	{
		var out:Dynamic = {};
		for (entry in FileSystem.readDirectory(sourceDir))
		{
			
			if (FileSystem.isDirectory(Path.join([sourceDir, entry])))
			{
				var value = _collect(Path.join([sourceDir, entry]), Path.join([runtimeDir, entry]), extensions);				
				Reflect.setField(out, sanitize(entry), value); 					
			} else {
				
				if (extensions.indexOf(Path.extension(entry)) > -1)
				{
					var name = sanitize(entry);
					var newValue = Path.join([runtimeDir, entry]);					
					var oldValue = Reflect.field(out, name);
					if (oldValue != null)
					{
						
						var newExt = Path.extension(newValue);
						var exts = Path.extension(oldValue).split(",");						
						exts.push(newExt);
						
						sortByPriority(exts, extensions);
						
						newValue = Path.withoutExtension(newValue) + "." + exts.join(",");
					}
					
					Reflect.setField(out, name, newValue);
				}
			}
		}
		
		return out;
	}
	#end
	
	static function sortByPriority<T>(array:Array<T>, priority:Array<T>)
	{
		function sort(a:T, b:T)	return priority.indexOf(a) - priority.indexOf(b);
		
		array.sort(sort);
	}
	
	static function sanitize(name:String):String
	{		
		return Path.withoutExtension(name)
			.replace(".", "_")
			.replace("-", "_")
			.replace("!", "_")
			.replace("/", "_");
	}
}