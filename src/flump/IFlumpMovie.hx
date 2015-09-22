package flump;

import flump.library.*;


@:allow(flump)
interface IFlumpMovie{

	private var master:Bool;

	private function beginSetup():Void;
	private function createLayer(layer:Layer):Void;
	private function endSetup():Void;

	private function startRender():Void;
	private function completeRender():Void;

	private function createFlumpChild(displayKey:DisplayObjectKey):Void;
	private function removeFlumpChild(layer:Layer, displayKey:DisplayObjectKey):Void;
	private function addFlumpChild(layer:Layer, displayKey:DisplayObjectKey):Void;

	private function renderFrame(keyframe:Keyframe, x:Float, y:Float, scaleX:Float, scaleY:Float, skewX:Float, skewY:Float):Void;
	private function renderMovieFrame(keyframe:Keyframe, x:Float, y:Float, scaleX:Float, scaleY:Float, skewX:Float, skewY:Float):MoviePlayer;
	private function getChildMovie(keyframe:Keyframe):MoviePlayer;
	private function renderEmptyFrame(keyframe:Keyframe):Void;

	private function labelEnter(label:Label):Void;
	private function labelExit(label:Label):Void;

}

