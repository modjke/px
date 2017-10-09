package px.psd2px;

@:enum abstract EntryType(String)
{
	var SPRITE = "sprite";
	var BUTTON = "button";
	var RECT = "rect";
	var POINT = "point";
	var TEXTURE = "texture";
}

typedef PsdEntry = {
	id:String,
	x:Float,
	y:Float,
	
	//fields below added by converting psd json for macro
	?type:EntryType,
	?image:String,
	
	//for EntryType.BUTTON
	?overImage:String,
	?overOffset: { x:Float, y: Float },
	
	//for EntryType.RECT
	?width:Float,
	?height:Float,
	
	//if entry has pivot
	?pivot: { x:Float, y:Float },
	
	//for EntryType.TEXTURE
	?anchor: { x:Float, y: Float },
	
};