package pixi.display;

import flump.*;
import flump.DisplayObjectKey;
import flump.library.*;
import flump.library.MovieSymbol;
import pixi.display.FlumpResource;
import pixi.extras.MovieClip;
import pixi.core.display.Container;
import pixi.core.display.DisplayObject;
import pixi.core.math.Point;
import pixi.core.ticker.Ticker;


@:access(pixi.display.FlumpResource)
class FlumpMovie extends Container implements IFlumpMovie {

	public var player:MoviePlayer;
	private var symbol:MovieSymbol;
	private var layers = new Map<Layer, PixiLayer>();
	private var layerLookup = new Map<String, Container>();
	private var movieChildren = new Map<DisplayObjectKey, DisplayObject>();
	private var displaying = new Map<Layer, DisplayObjectKey>();
	private var ticker:Ticker = untyped __js__ ("PIXI.ticker.shared");
	private var master:Bool;

	private var resource:FlumpResource;
	private var resourceId:String;
	

	public function new(symbolId:String, resourceId:String = null){
		super();
		this.resourceId = resourceId;

		if(resourceId == null){
			resource = FlumpResource.getResourceForMovie(symbolId);
			if(resource == null) throw("Flump movie does not exist: " + symbolId);
		}else{
			resource = FlumpResource.get(resourceId);
			if(resource == null) throw("Flump resource does not exist: " + resourceId);
		}

		this.symbol = resource.library.movies.get(symbolId);
		
		player = new MoviePlayer(symbol, this);	
		this.loop = true;

		master = true;
		once("added", onAdded);
	}


	private function disableAsMaster(){
		master = false;
		off("added", onAdded);
	}


	/////////////////////////////////////////////////////
	//
	//   API
	//
	/////////////////////////////////////////////////////

	public var animationSpeed(default, default):Float = 1.0;

	public function getLayer(layerId:String):Container{
		if(layerLookup.exists(layerId) == false) throw("Layer " + layerId + "does not exist");
		return layerLookup[layerId];
	}


	public function getChildDisplayObject(layerId:String, keyframeIndex:UInt = 0):DisplayObject{
		var key = player.getDisplayKey(layerId, keyframeIndex);
		return movieChildren[key];
	}


	public function getChildMovie(layerId, keyframeIndex:UInt = 0):FlumpMovie{
		var child = getChildDisplayObject(layerId, keyframeIndex);
		if(Std.is(child, FlumpMovie) == false) throw("Child on layer " + layerId + " at keyframeIndex " + keyframeIndex + " is not of type FlumpMovie!");
		return cast child;
	}


	public var symbolId(get, null):String;
	private function get_symbolId(){
		return symbol.name;
	}

	public var loop(default, set):Bool;
	private function set_loop(value){
		if(value && player.playing) player.loop();
		else if(value == false && player.looping) player.play();
		return loop = value;
	}


	public var onComplete(default, set):Void -> Void;
	private function set_onComplete(value){
		return onComplete = value;
	}

	public var currentFrame(get, set):Int;
	private function set_currentFrame(value){
		player.currentFrame = value;
		return value;
	}
	private function get_currentFrame():Int{
		return player.currentFrame;
	}

	public var playing(get, null):Bool;
	private function get_playing(){
		return player.playing || player.looping;
	}


	public var independantTimeline(get, set):Bool;
	private function get_independantTimeline(){
		return player.independantTimeline;
	}
	private function set_independantTimeline(value:Bool){
		player.independantTimeline = value;
		return value;
	}


	public var independantControl(get, set):Bool;
	private function get_independantControl(){
		return player.independantControl;
	}
	private function set_independantControl(value:Bool){
		player.independantControl = value;
		return value;
	}


	public var totalFrames(get, null):Int;
	private function get_totalFrames(){
		return player.totalFrames;
	}


	public function stop():Void{
		player.stop();
	}


	public function play():Void{
		if(loop) player.loop();
		else player.play();
	}


	public function gotoAndStop(frameNumber:Int):Void{
		if(!loop){
			if(frameNumber > player.totalFrames-1) frameNumber = player.totalFrames - 1;
			else if(frameNumber < 0) frameNumber = 0;
		}
		player.goToFrame(frameNumber).stop();
	}


	public function gotoAndPlay(frameNumber:Int):Void{
		if(!loop){
			if(frameNumber > player.totalFrames-1) frameNumber = player.totalFrames - 1;
			else if(frameNumber < 0) frameNumber = 0;
		}
		if(loop) player.goToFrame(frameNumber).loop();
		else player.goToFrame(frameNumber).play();
	}


	public function getLabelFrame(label:String):UInt{
		return player.getLabelFrame(label);
	}


	/////////////////////////////////////////////////////
	//
	//   Other
	//
	/////////////////////////////////////////////////////

	private function tick(){
		player.advanceTime(ticker.elapsedMS * animationSpeed);
	}


	private function onAdded(to){
		once("removed", onRemoved);
		ticker.add(tick);
	}


	private function onRemoved(from){
		once("added", onAdded);
		ticker.remove(tick);
	}



	/////////////////////////////////////////////////////
	//
	//   IFlumpMovie
	//
	/////////////////////////////////////////////////////

	
	
	private function createLayer(layer:Layer):Void{
		layers[layer] = new PixiLayer();
		layerLookup[layer.name] = layers[layer];
		addChild(layers[layer]);
	}


	private function getChildPlayer(keyframe:Keyframe):MoviePlayer{
		var movie:FlumpMovie = cast movieChildren[keyframe.displayKey];
		return movie.player;
	}


	private function createFlumpChild(displayKey:DisplayObjectKey):Void{
		movieChildren[displayKey] = resource.createDisplayObject(displayKey.symbolId);
	}


	private function removeFlumpChild(layer:Layer, displayKey:DisplayObjectKey):Void{
		var layer = layers[layer];
		layer.removeChildren();
	}


	private function addFlumpChild(layer:Layer, displayKey:DisplayObjectKey):Void{
		var layer = layers[layer];
		layer.addChild( movieChildren[displayKey] );
	}


	private function onAnimationComplete():Void{
		if(onComplete != null) onComplete();
	}


	private function renderFrame(keyframe:Keyframe, x:Float, y:Float, scaleX:Float, scaleY:Float, skewX:Float, skewY:Float):Void{
		var layer = layers[keyframe.layer];
		layer.x = x;
		layer.y = y;
		layer.scale.x = scaleX;
		layer.scale.y = scaleY;
		layer.skew.x = skewX;
		layer.skew.y = skewY;
		layer.pivot.x = keyframe.pivot.x;
		layer.pivot.y = keyframe.pivot.y;
	}


	private function labelPassed(label:Label){
		emit("labelPassed", label.name);
	}
	
	override public function destroy(): Void {
		stop();
		onComplete = null;
		for (layer in layers) layer.removeChildren();
		symbol = null;
		player = null;
		super.destroy(true);
	}


}