package px.psd2px;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;


class ShoeBox 
{
	var exePath:String;
	
	public function new(exePath:String) 
	{
		if (!FileSystem.exists(exePath)) throw 'ShoeBox executable was not found @ $exePath';
		
		this.exePath = exePath;
	}
	
	public function splitPsd(psdPath:String, jsonFileName:String)
	{
		psdPath = FSUtil.makeAbsolute(psdPath);
		var jsonPath = Path.join([Path.directory(psdPath), jsonFileName]);
		//remove json file
		if (FileSystem.exists(jsonPath))
			FileSystem.deleteFile(jsonPath);
		
		var p = new Process(exePath, [
			'plugin=shoebox.plugin.splitPSD::PluginSplitPSD',
			'files=$psdPath',
			'textFileDataLoop=\\t{ \"id\": \"@id\", \"x\": @x, \"y\": @y },\\n', 
			'textFileDataOuter=[\\n@loop\\n]',
			'textFileName=$jsonFileName',
			'ignoreLayerNoBkgSize=false',
			'ignoreLayerSizeMin=0',
			'spriteFileNames=@name.png'
		]);
		 
		p.exitCode(true);
		
		//fix json file
		//to be valid remove comma after the last item in the array
		
		if (FileSystem.exists(jsonPath))
		{
			var content = File.getContent(jsonPath);
			var lastComma = content.lastIndexOf(",");
			content = content.substr(0, lastComma) + "\n]";
			File.saveContent(jsonPath, content);
		} else
			throw '$jsonFileName could not be found, did psd split succeeded?';
	}
	
	public function spriteSheet(pngs:Array<String>, fileName:String)
	{
		var files = pngs.map(FSUtil.makeAbsolute).join(",");
		
		var p = new Process(exePath, [
			'plugin=shoebox.plugin.spriteSheet::PluginCreateSpriteSheet',
			'files=$files',
			'texPadding=1',
			'renderDebugLayer=false',
			'fileName=$fileName.json',
			'animationMaxFrames=100',
			'useCssOverHack=false',
			'texMaxSize=2048',
			'fileGenerate2xSize=false',
			'texExtrudeSize=0',
			'texSquare=false',
			'animationNameIds=@name_###.png',
			'texCropAlpha=false',
			'animationFrameIdStart=0',
			'scale=1',
			'fileFormatOuter={\n\"frames\": {\n@loop\n},\n\"meta\": {\n\t\"image\": \"@TexName\",\n\t\"size\": {\"w\": @W, \"h\": @H},\n\t\"scale\": \"1\"\n}\n}',
			'texPowerOfTwo=true',
			'fileFormatLoop=\t\"@id\": {\n\t\t\"frame\": {\"x\":@x, \"y\":@y, \"w\":@w, \"h\":@h},\n\t\t\"spriteSourceSize\": {\"x\":@fx,\"y\":@fy,\"w\":@fw,\"h\":@fh},\n\t\t\"sourceSize\": {\"w\":@fw,\"h\":@fh}\n\t}@,\n'
		]);
		p.exitCode(true);
	}
}