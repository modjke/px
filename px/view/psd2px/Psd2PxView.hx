package px.view.psd2px;

import pixi.core.display.DisplayObject;
import px.PxAssets;

@:autoBuild(px.macros.Psd2Px.build())
interface Psd2PxView
{
	function createView(assets:PxAssets):Void;
	function addChild<T:DisplayObject>(child:T):T;
}