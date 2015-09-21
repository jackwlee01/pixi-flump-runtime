package flump;

import flump.library.Keyframe;
import flump.library.Layer;


interface FlumpMovie{

	function beginSetup():Void;
	function createLayer(layer:Layer):Void;
	function endSetup():Void;

	function startRender():Void;
	function completeRender():Void;

	function renderFrame(keyframe:Keyframe, x:Float, y:Float, scaleX:Float, scaleY:Float, skewX:Float, skewY:Float):Void;
	function renderMovieFrame(keyframe:Keyframe, x:Float, y:Float, scaleX:Float, scaleY:Float, skewX:Float, skewY:Float):MoviePlayer;
	function getChildMovie(keyframe:Keyframe):MoviePlayer;
	function renderEmptyFrame(keyframe:Keyframe):Void;

}

