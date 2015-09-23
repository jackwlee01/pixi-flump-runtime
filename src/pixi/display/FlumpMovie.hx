package pixi.display;

import flump.*;
import flump.DisplayObjectKey;
import flump.library.*;
import flump.library.MovieSymbol;
import pixi.extras.MovieClip;
import pixi.core.display.Container;
import pixi.core.display.DisplayObject;
import pixi.core.math.Point;
import pixi.core.ticker.Ticker;


@:access(pixi.display.FlumpFactory)
class FlumpMovie extends Container implements IFlumpMovie{

	public var player:MoviePlayer;
	private var symbol:MovieSymbol;
	private var layers = new Map<Layer, PixiLayer>();
	private var layerLookup = new Map<String, Container>();
	private var movieChildren = new Map<DisplayObjectKey, DisplayObject>();
	private var displaying = new Map<Layer, DisplayObjectKey>();
	private var ticker:Ticker = untyped __js__ ("PIXI.ticker.shared");
	private var master:Bool;

	private var factory:FlumpFactory;


	private function new(symbol:MovieSymbol, flumpFactory:FlumpFactory, master:Bool){
		super();
		this.symbol = symbol;
		factory = flumpFactory;
		this.master = master;
		player = new MoviePlayer(symbol, this);	

		if(master) once("added", onAdded);
	}



	/////////////////////////////////////////////////////
	//
	//   API
	//
	/////////////////////////////////////////////////////


	public var animationSpeed(default, default):Float = 1.0;

	public var symbolId(get, null):String;
	private function get_symbolId(){
		return symbol.name;
	}

	public var loop(default, set):Bool;
	private function set_loop(value){
		return loop = value;
	}


	public var onComplete(default, set):Void -> Void;
	private function set_onComplete(value){
		return null;
	}

	public var currentFrame(default, set):Int;
	private function set_currentFrame(value){
		player.currentFrame = value;
		return value;
	}

	public var playing(get, null):Bool;
	private function get_playing(){
		return player.playing;
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
		player.goToFrame(frameNumber).stop();
	}


	public function gotoAndPlay(frameNumber:Int):Void{
		if(loop) player.goToFrame(frameNumber).play();
		else player.goToFrame(frameNumber).stop();
	}


	public function getLayer(name:String){
		return layerLookup[name];
	}


	public function onLabelEnter(label:String, callback:Void->Void){
		if(!player.labelExists(label)) throw("Label " + label + "does not exist for movie " + symbol.name); 
		this.on("enter_" + label, callback);
	}


	public function onLabelExit(label:String, callback:Void->Void){
		if(!player.labelExists(label)) throw("Label " + label + "does not exist for movie " + symbol.name); 
		this.on("exit_" + label, callback);
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
		movieChildren[displayKey] = factory.createChildDisplayObject(displayKey.symbolId);
	}


	private function removeFlumpChild(layer:Layer, displayKey:DisplayObjectKey):Void{
		var layer = layers[layer];
		layer.removeChildren();
	}


	private function addFlumpChild(layer:Layer, displayKey:DisplayObjectKey):Void{
		var layer = layers[layer];
		layer.addChild( movieChildren[displayKey] );
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


	private function labelEnter(label:Label){
		this.emit("enter_" + label, this);
	}


	private function labelExit(label:Label){
		this.emit("exit_" + label, this);
	}

}