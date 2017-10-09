package px.psd2px;
import haxe.io.Path;
import sys.FileSystem;
using Lambda;

class FSUtil 
{

	/**
	 * Removes all files from the directory ignoring file with extensions from exceptExtension param
	 * Non-recursive
	 */
	public static function cleanDirectory(dir:String, exceptExtensions:Array<String>)
	{
		for (entry in FileSystem.readDirectory(dir))
		{
			var path = Path.join([dir, entry]);
			if (!FileSystem.isDirectory(path) &&
				!exceptExtensions.has(Path.extension(path)))
				FileSystem.deleteFile(path);
		}
	}
	
	public static function makeAbsolute(path:String):String
	{
		if (Path.isAbsolute(path))
			return path;
		else 
			return Path.join([Sys.getCwd(), path]);
	}
	
	public static function removeFiles(files:Array<String>)
	{
		for (f in files)		
			if (FileSystem.exists(f) && !FileSystem.isDirectory(f))
				FileSystem.deleteFile(f);				
	}
	
	public static function findFiles(dir:String, fileType:String, recursive = true):Array<String>
	{
		var files:Array<String> = [];
		
		_findFiles(dir, fileType, recursive, files);
		
		return files;
	}
	
	static function _findFiles(dir:String, extenstion:String, recursive:Bool, files:Array<String>)
	{
		for (e in FileSystem.readDirectory(dir))
		{
			var path = Path.join([dir, e]);
			if (FileSystem.isDirectory(path))
			{
				if (recursive)
					_findFiles(path, extenstion, recursive, files);
			} else {
				if (Path.extension(path) == extenstion)
					files.push(path);
			}
			
		}
	}
}