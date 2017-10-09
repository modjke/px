package px.view;

import pixi.core.sprites.Sprite;
import pixi.core.textures.Texture;
import px.utils.PxTextureUtils;


class PxSprite extends Sprite 
{
	@:keep
	public var scaleX(get, set):Float;	
	function get_scaleX() return scale.x;
	function set_scaleX(v:Float) return scale.x = v;

	@:keep
	public var scaleY(get, set):Float;
	function get_scaleY() return scale.y;
	function set_scaleY(v:Float) return scale.y = v;
	

	public function new(texture:Texture, adjustPositionForDefaultPivorOrAnchor = true) 
	{
		super(texture);
		
		PxTextureUtils.getDefaultAnchor(texture, this.anchor);
		PxTextureUtils.getDefaultPivot(texture, this.pivot);

		if (adjustPositionForDefaultPivorOrAnchor)
		{
			position.x += pivot.x + anchor.x * texture.width;
			position.y += pivot.y + anchor.y * texture.height;
		}
		
	}
	
}