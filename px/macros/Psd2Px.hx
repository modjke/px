package px.macros;
import haxe.Json;
import haxe.PosInfos;
import haxe.io.Eof;
import haxe.io.Path;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Expr.Field;
import px.psd2px.PsdProcessor;

import px.psd2px.PsdEntry;


using StringTools;
using Lambda;


#if macro
import px.psd2px.Modified;
import sys.io.File;
import sys.io.Process;
#end

class Psd2Px 
{
	public static var DEFAULT_DIR = "bin";
	
	/**
	 * Creates array expression with all the local class fields that match regEx
	 * @param	regEx fields with names matching this regEx will be added to final array
	 * @param	sortByNameAsc true - sort by name asc, false - desc, if not set = no sort
	 * @return
	 */
	macro public static function arrayOfFieldsThatMatch(regEx:ExprOf<EReg>, ?sortByNameAsc:Bool):Expr
	{		
		var er:EReg = null;
		switch (regEx.expr)
		{
			case EConst(CRegexp(r, opt)): 				
				er = new EReg(r, opt);
			case _: throw "Invalid parameter";
		};
		
		var localClass = Context.getLocalClass().get();
		var fields = localClass.fields.get();
		var matched:Array<String> = [];
		for (f in fields)
			if (er.match(f.name))
				matched.push(f.name);
				
		if (sortByNameAsc != null)
		{			
			matched.sort(
				sortByNameAsc ? 
					Reflect.compare : 
					function (a, b) return -1 * Reflect.compare(a, b) 
			);
		}

		return macro $a{matched.map(function (name) return macro $i{name})};
	}
	
	macro public static function build():Array<Field>
	{		
		var psdPath:String = extractMetaValue("psd");
		var binPath:String = extractMetaValue("dir");
		
		if (psdPath == null) return Context.getBuildFields();
		if (binPath == null) binPath = DEFAULT_DIR;
		
		var binPsdPath = Context.resolvePath(Path.join([binPath, psdPath]));

		#if !display
			#if psd2px_force
				runPsd2Px(binPsdPath, true);
			#else
			if (Modified.isModified(binPsdPath))
				runPsd2Px(binPsdPath);
			#end
		#end
		
		var fields = Context.getBuildFields();
		
		var atlasPath = Path.withExtension(psdPath, "json");
		
		fields.push(createStaticAtlas(atlasPath));
		
			
		var viewPath = Path.join([binPath, Path.withExtension(psdPath, "view")]);
		var viewJson:Array<PsdEntry> = Json.parse(File.getContent(Context.resolvePath(viewPath)));		

		var createBlocks:Array<Expr> = [];
		var textures:Array<{ id:String, image:String }> = [];

		for (entry in viewJson)
		{
			
			var type = switch (entry.type)
			{
				case BUTTON: macro:px.view.PxButton; 
				case SPRITE: macro:px.view.PxSprite;
				case RECT: 	 macro:pixi.core.math.shapes.Rectangle;
				case POINT:  macro:pixi.core.math.Point;
				case TEXTURE: macro:pixi.core.textures.Texture;
			}
			
			var expr:Expr = switch (entry.type)
			{
				case BUTTON: 					
					macro {						
						var normal = getFrame($v{entry.image});
						var over:pixi.core.textures.Texture = ${
							entry.overImage != null ? macro getFrame($v{entry.overImage}) : macro null					
						};
						
						var offset:pixi.core.math.Point = ${
							entry.overOffset != null ? macro new pixi.core.math.Point($v{entry.overOffset.x}, $v{entry.overOffset.y}) : macro null
						};
											
						$i{entry.id} = this.addChild(new px.view.PxButton(normal, over, offset));
						$i{entry.id}.name = $v{entry.id};
						$i{entry.id}.position.set($v{entry.x}, $v{entry.y});						
					}
				case SPRITE: 
					macro {
						var texture = getFrame($v{entry.image});						
						
						$i{entry.id} = this.addChild(new px.view.PxSprite(texture));
						$i{entry.id}.name = $v{entry.id};
						
						${ entry.pivot != null ? macro {
							$i{entry.id}.pivot.set($v{entry.pivot.x}, $v{entry.pivot.y});
						} : macro {}};
						
						${ entry.anchor != null ? macro {
							$i{entry.id}.anchor.set($v{entry.anchor.x}, $v{entry.anchor.y});
						} : macro {}};
						
						$i{entry.id}.position.set($v{entry.x}, $v{entry.y});
					}
					
				case RECT:
					macro $i{entry.id} = new pixi.core.math.shapes.Rectangle($v{entry.x}, $v{entry.y}, $v{entry.width}, $v{entry.height});
					
				case POINT:					
					macro $i{entry.id} = new pixi.core.math.Point($v{entry.x}, $v{entry.y});
					
				case TEXTURE:					
					textures.push({
						id: entry.id,
						image: entry.image
					});
					//macro $i{entry.id} = getFrame($v{entry.image});
					//do not create texture vars
					null;
					
			}
		
			if (expr != null)
			{
				var f:Field = {
					name: entry.id,
					access: [APublic],
					kind: FVar(type),
					pos: Context.currentPos(),
				};
				
				fields.push(f);
				
				createBlocks.push(expr);
			}
			
		}
		
		fields.push(createStaticTextures(textures));
				
		var createChildrenOverride:Field = {
			name: "createView",
			access: [APublic],
			kind: FFun({
				args: [ { type: macro:px.PxAssets, name: "assets" } ],
				expr: macro {
					var frames = assets.getAtlas(ATLAS);
					
					inline function getFrame(name:String):pixi.core.textures.Texture
						return untyped frames[name];
						
					$b{createBlocks};
				},
				ret: null,
			}),
			pos: Context.currentPos(),
		};
		
		fields.push(createChildrenOverride);
		
		return fields;
	}
	
	
	#if macro
	static function createStaticTextures(textures:Array<{id:String, image:String}>)
	{
		var json:Dynamic = {};
		for (t in textures)
			Reflect.setField(json, t.id, t.image);
			
		var field:Field = {
			name: "TEXTURES",
			access: [AStatic, APublic],
			kind: FVar(null, macro $v{json}),
			pos: Context.currentPos(),
		};
		
		return field;
	}
	
	static function createStaticAtlas(atlasJson:String):Field
	{
		var field:Field = {
			name: "ATLAS",
			access: [AStatic, APublic],
			kind: FVar(macro:String, macro $v{atlasJson}),				
			pos:Context.currentPos(),
		};
		
		return field;
	}
	
	
	
	static function extractMetaValue(name:String):Null<String>
	{
		var localClass = Context.getLocalClass().get();
		var metas = localClass.meta.extract(name);
		if (metas.length == 0)
			return null;
			
		var p = metas[0].params[0];
		return switch (p.expr)
		{
			case EConst(CString(v)): v;
			case _: null;
		}
	}
	
	static function runPsd2Px(psdPath:String, force = false)
	{
		try {
			PsdProcessor.convertPsd(psdPath, force);
		} catch (error:Dynamic)
		{
			Context.fatalError('PsdProcessor exception: ${error}', Context.currentPos());
		}
		
	}
	#end
	
	static function sanitize(name:String):String
	{		
		return name
			.replace(" ", "_")
			.replace(".", "_")
			.replace("-", "_")
			.replace("!", "_")
			.replace("/", "_");
	}
	
	
}