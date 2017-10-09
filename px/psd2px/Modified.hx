package px.psd2px;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;

using Lambda;

class Modified 
{

	static var EXT = "psd2px";
	
	public static function getModified(files:Array<String>)
	{
		return files.filter(isModified);
	}
	
	public static function isModified(path:String)
	{
		var dataFile = Path.withExtension(path, EXT);
		var fileContent = contentOrNull(dataFile);
		if (fileContent == null)
			return true;
		
		var date = dateOrNull(fileContent);
		if (date == null)
			return true;
			
		var stat = FileSystem.stat(path);
		return Std.int(stat.mtime.getTime() / 1000) != Std.int(date.getTime() / 1000);
	}
	
	public static function markAsUnmodified(file:String)
	{
		var stat = FileSystem.stat(file);
		File.saveContent(Path.withExtension(file, EXT), stat.mtime.toString());
	}
	
	static function dateOrNull(str:String):Date
	{
		var out:Date = null;
		try {
			out = Date.fromString(str);
		} catch (any:Dynamic) {}
		
		return out;
	}
	
	static function contentOrNull(file:String)
	{
		if (FileSystem.exists(file) && !FileSystem.isDirectory(file))
			return File.getContent(file);
		
		return null;
	}
}