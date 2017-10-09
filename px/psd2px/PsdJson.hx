package px.psd2px;
import haxe.Json;
import haxe.io.Path;
import px.psd2px.Png;
import sys.FileSystem;
import sys.io.File;
using StringTools;
using Lambda;


class PsdJson 
{

	var filePath:String;
	var content:Array<PsdEntry>;
	var converted = false;
	var pivotAndAnchorsPngs:Array<String> = [];
	
	public function new(filePath:String) 
	{
		this.filePath = filePath;
		this.content = Json.parse(File.getContent(filePath));
	}
	
	public function convertForMacro()
	{
		if (converted)
		{
			Sys.println("convertForMacro() called twice, ignoring...");
			return;
		}
		
		converted = true;
		
		for (e in content)		
		{			
			e.id = sanitize(e.id);			
			e.image = e.id + ".png";
		}
		
		var newContent:Array<PsdEntry> = [];
		for (e in content)
		{		
			Sys.println('Processing entry: ${e.id}');
			
			var suffix = getSuffix(e.id);

			switch (suffix)
			{
				case "over": 
					continue;	
					
				case "pivot" | "anchor":
					pivotAndAnchorsPngs.push(Path.join([Path.directory(filePath), e.image]));
					continue;					
				
				case "rect":
					e.type = RECT;
				case "point":
					e.type = POINT;					
				case "normal":
					e.type = BUTTON;		
				case "texture":
					e.type = TEXTURE;
				case _:
					e.type = SPRITE;					
					
			}

			var pivot = findPivot(e);		 
			
			var anchor = findAnchor(e);
			var pngPath = Path.join([Path.directory(filePath), e.image]);
			
			switch (e.type)
			{
				case SPRITE:					
					e.pivot = pivot;
					e.anchor = anchor;
					
					var pngSize = Png.size(pngPath);
					e.width = pngSize.width;
					e.height = pngSize.height;
					
					if (e.pivot != null)
					{					
						e.x += pivot.x;
						e.y += pivot.y;
					}
					
					if (e.anchor != null)
					{
						e.x += e.anchor.x * e.width;
						e.y += e.anchor.y * e.height;
					}
					
				case BUTTON:
					var overEntry = findEntry(e.id, "over");
					if (overEntry != null)
					{					
						e.overImage = overEntry.id + ".png";
						e.overOffset = {
							x: e.x - overEntry.x,
							y: e.y - overEntry.y
						}												
					}
						
					
					e.pivot = pivot;
					if (anchor != null)
						Sys.println("Setting an anchor for the button makes not sense, since it has at least two textures, ignoring...");
						
					e.id = removeSuffix(e.id);
					
				case RECT:
					if (anchor != null)
						Sys.println("Anchor for the Rectangle makes to sense, ignoring...");
						
					if (pivot != null)
						Sys.println("Pivot for the Rectangle makes no sense, ignoring...");
						
					
					var pngSize = Png.size(pngPath);
					e.width = pngSize.width;
					e.height = pngSize.height;

					e.id = removeSuffix(e.id);
				case POINT:
					if (anchor != null)
						Sys.println("Anchor for the Point makes to sense, ignoring...");
						
					if (pivot != null)
						Sys.println("Pivot for the Point makes no sense, ignoring...");
						
					var pngSize = Png.size(pngPath);
					//point in the middle
					e.x += pngSize.width * .5;
					e.y += pngSize.height * .5;
					
					e.id = removeSuffix(e.id);
					
				case TEXTURE:
					e.pivot = pivot;
					e.anchor = anchor;
					
					e.id = removeSuffix(e.id);					
			};
			
			newContent.push(e);
		}
		
		this.content = newContent;
	}
	
	public function save()
	{
		File.saveContent(filePath, Json.stringify(content, null, "  "));
	}
	
	
	/**
	 * Get all entries with texture type
	 * @return
	 */
	public function getTextureEntries():Array<PsdEntry>
	{
		if (!converted) throw "PsdJson should be converted first, call convertForMacro()";
		
		return content.filter(function (e) return e.type == TEXTURE);
	}
	
	/**
	 * Finds with same id & new suffix
	 * @param	id
	 * @param	suffix
	 * @return
	 */
	function findEntry(id:String, suffix:String):Null<PsdEntry>
	{
		var newId = setSuffix(id, suffix);
		var entry = content.find(function (e) return e.id == newId);
		return entry;
	}
	
	/**
	 * Finds a pivot point for the specified entry
	 * @param	entry
	 * @return
	 */
	function findPivot(e:PsdEntry):Null<{x:Float,y:Float}>
	{
		var p:{x:Float, y:Float} = null;
		var pEntry = findEntry(e.id, "pivot");
		if (pEntry != null)
		{			
			var pivotSize = Png.size(Path.join([Path.directory(filePath), pEntry.image]));
			var imageSize = Png.size(Path.join([Path.directory(filePath), e.image]));
			
			p = {
				x: pEntry.x - e.x + pivotSize.width * .5,
				y: pEntry.y - e.y + pivotSize.height * .5
			}
		}
		return p;
	}
	
	/**
	 * Finds a anchor point for the specified entry
	 * @param	entry
	 * @return
	 */
	function findAnchor(e:PsdEntry):Null<{x:Float,y:Float}>
	{
		var p:{x:Float, y:Float} = null;
		var pEntry = findEntry(e.id, "anchor");
		if (pEntry != null)
		{			
			var anchorSize = Png.size(Path.join([Path.directory(filePath), pEntry.image]));
			var imageSize = Png.size(Path.join([Path.directory(filePath), e.image]));
			
			p = {
				x: (pEntry.x - e.x + anchorSize.width * .5) / imageSize.width,
				y: (pEntry.y - e.y + anchorSize.height * .5) / imageSize.height
			}
		}
		return p;
	}
	
	function getPngList(spritesheet:Bool):Array<String>
	{
		if (!converted) throw "PsdJson should be converted first, call convertForMacro()";
		
		var dir = Path.directory(filePath);
		var pngs:Array<String> = [];
		
		
		for (e in content)
		{
			switch (e.type)
			{
				case TEXTURE:
					pngs.push(Path.join([dir, e.image]));
					
				case SPRITE:					
					pngs.push(Path.join([dir, e.image]));

				case BUTTON:
					pngs.push(Path.join([dir, e.image]));
					if (e.overImage != null)
						pngs.push(Path.join([dir, e.overImage]));		
						
				case RECT | POINT:					
					if (!spritesheet)				
						pngs.push(Path.join([dir, e.image]));			 
			}
		}
		
		
		
		if (!spritesheet)
			pngs = pngs.concat(pivotAndAnchorsPngs);
			
		
		return pngs;
	}
	
	public function getPngs(spritesheet:Bool):Array<String>
	{
		if (!converted) throw "PsdJson should be converted first, call convertForMacro()";
		
		var pngs = getPngList(spritesheet);		
		for (png in pngs)
			if (!FileSystem.exists(png))
				throw 'File doest not exists: $png';
				
		return pngs;
	}
	
	function getSuffix(name:String):String {
		var index = name.lastIndexOf("_");		
		return index > -1 ? name.substr(index + 1) : null;
	}
	
	function removeSuffix(name:String):String
	{
		var index = name.lastIndexOf("_");
		return index > -1 ? name.substring(0, index) : name;
	}
	
	function setSuffix(name:String, suffix:String):String
	{
		return removeSuffix(name) + "_" + suffix;
	}
	
	function sanitize(id:String):String
	{
		return id.replace(" ", "_");
	}
}