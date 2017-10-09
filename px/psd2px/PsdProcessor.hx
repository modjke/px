package px.psd2px;

import haxe.io.Path;
#if sys
import px.psd2px.FSUtil;
import sys.FileSystem;
#end

using StringTools;

class PsdProcessor
{
	#if sys
	static var shoeBoxExe = "C:\\Program Files (x86)\\ShoeBox\\ShoeBox.exe";

	/**
	 * Splits psd file with shoebox utility and packs it into texture atlas
	 * In the same folder as psd these files will be created
	 * atlas.json, atlas.png - texture atlas
	 * psd.json - manifest for the Psd2Px macro
	 * @param	psd - path to psd
	 */
	public static function convertPsd(psd:String, force:Bool = false)
	{
		if (!FileSystem.exists(psd))
			throw 'File not found: $psd';
			
		if (!force && !Modified.isModified(psd))		
			return;
		
		var psdName = Path.withoutExtension(Path.withoutDirectory(psd));
		
		Sys.println('Processing $psd...');
		
		var psdDir = Path.directory(psd);
		
		//Sys.println('Cleaning directory $psdDir...');
		//FSUtil.cleanDirectory(psdDir, ["psd"]);
		
		Sys.println('Splitting ${Path.withoutDirectory(psd)}...');
		var shoeBox = new px.psd2px.ShoeBox(shoeBoxExe);
		
		var psdJsonName = '$psdName.view';
		shoeBox.splitPsd(psd, psdJsonName);
		
		var psdJsonPath = Path.join([psdDir, psdJsonName]);
		
		Sys.println('Parsing $psdJsonName...');
		var psdJson = new PsdJson(psdJsonPath);				
		psdJson.convertForMacro();
		
		var pngs = psdJson.getPngs(true);
	
		Sys.println('Creating sprite sheet...');
		var spriteSheetName = psdName;
		shoeBox.spriteSheet(pngs, spriteSheetName);
		
		Sys.println('Pushing additional texture info to $spriteSheetName...');
		var spritesheetJson = Path.join([psdDir, '$spriteSheetName.json']);
		
		PxSpritesheet.pushAdditionalTextureInfo(spritesheetJson, psdJson.getTextureEntries());
		
		Sys.println('Cleaning pngs...');
		
		var pngs2keep = PxSpritesheet.retrievePngsPaths(spritesheetJson);
		var pngs2remove = psdJson.getPngs(false)
			.filter(function (path) return pngs2keep.indexOf(path) == -1);
		
		px.psd2px.FSUtil.removeFiles(pngs2remove);
		
		Sys.println('Saving $psdJsonName');
		psdJson.save();
		
	}
	
	#end
}