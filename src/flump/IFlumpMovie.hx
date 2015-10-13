package flump;

import flump.library.*;


@:allow(flump)
interface IFlumpMovie{

	private function createLayer(layer:Layer):Void;
	private function createFlumpChild(displayKey:DisplayObjectKey):Void;
	private function removeFlumpChild(layer:Layer, displayKey:DisplayObjectKey):Void;
	private function addFlumpChild(layer:Layer, displayKey:DisplayObjectKey):Void;

	private function renderFrame(keyframe:Keyframe, x:Float, y:Float, scaleX:Float, scaleY:Float, skewX:Float, skewY:Float):Void;
	private function getChildPlayer(keyframe:Keyframe):MoviePlayer;

	private function onAnimationComplete():Void;
	
	private function labelPassed(label:Label):Void;

}

