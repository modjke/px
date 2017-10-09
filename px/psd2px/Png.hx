package px.psd2px;
import sys.io.File;
import sys.io.FileOutput;
import sys.io.FileSeek;

class Png 
{

	public static function size(file:String):{width:Int, height:Int}
	{		
		var f = File.read(file, true);
		f.bigEndian = true;
		
		inline function nextByteIs(v:Int)
			if (f.readByte() != v)
				throw 'File format error';
				
		nextByteIs(137); 
		nextByteIs(80);
		nextByteIs(78);
		nextByteIs(71);
		nextByteIs(13);
		nextByteIs(10);
		nextByteIs(26);
		nextByteIs(10);
		
		//4 chunk size, 4 chunk name
		f.seek(8, FileSeek.SeekCur);
		
		var width = f.readInt32();
		var height = f.readInt32();
		
		f.close();
		
		return {
			width: width,
			height: height
		}
	}
	
	
	
}