package pixi.flump;

import flump.*;
import flump.filters.AnimateTintFilter;
import flump.library.*;
import pixi.core.display.Container;
import pixi.core.display.DisplayObject;
import pixi.core.graphics.Graphics;
import pixi.core.math.shapes.Rectangle;
import pixi.core.sprites.Sprite;
import pixi.core.ticker.Ticker;
import pixi.flump.Resource;


@:access(pixi.flump.Resource)
class Movie extends Container implements IFlumpMovie {

	public var player:MoviePlayer;
	private var symbol:MovieSymbol;
	private var layers = new Map<Layer, Container>();
	private var layerLookup = new Map<String, Container>();
	private var movieChildren = new Map<DisplayObjectKey, DisplayObject>();
	private var displaying = new Map<Layer, DisplayObjectKey>();
	private var ticker:Ticker = untyped __js__ ("PIXI.ticker.shared");
	private var master:Bool;

	private var resolution:Float;
	private var resource:Resource;
	private var resourceId:String;

	public function new(symbolId:String, resourceId:String = null){
		
		super();
		this.resourceId = resourceId;

		if(resourceId == null){
			resource = Resource.getResourceForMovie(symbolId);
			if(resource == null) throw("Flump movie does not exist: " + symbolId);
		}else{
			resource = Resource.get(resourceId);
			if(resource == null) throw("Flump resource does not exist: " + resourceId);
		}

		this.resolution = resource.resolution;

		this.symbol = resource.library.movies.get(symbolId);
		
		player = new MoviePlayer(symbol, this, resolution);	
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

	public var resX(get, set):Float;
	public function get_resX():Float{
		return x / resolution;
	}
	public function set_resX(value:Float):Float{
		x = value * resolution;
		return value;
	}

	public var resY(get, set):Float;
	public function get_resY():Float{
		return y / resolution;
	}
	public function set_resY(value:Float):Float{
		y = value * resolution;
		return value;
	}

	public var resScaleX(get, set):Float;
	public function get_resScaleX():Float{
		return scale.x / resolution;
	}
	public function set_resScaleX(value:Float):Float{
		scale.x = value * resolution;
		return value;
	}

	public var resScaleY(get, set):Float;
	public function get_resScaleY():Float{
		return scale.y / resolution;
	}
	public function set_resScaleY(value:Float):Float{
		scale.y = value * resolution;
		return value;
	}

	
	public function getLayer(layerId:String):Container{
		if(layerLookup.exists(layerId) == false) throw("Layer " + layerId + "does not exist");
		return layerLookup[layerId];
	}


	public function getChildDisplayObject(layerId:String, keyframeIndex:UInt = 0):DisplayObject{
		var key = player.getDisplayKey(layerId, keyframeIndex);
		return movieChildren[key];
	}


	public function getChildMovie(layerId, keyframeIndex:UInt = 0):Movie{
		var child = getChildDisplayObject(layerId, keyframeIndex);
		if(Std.is(child, Movie) == false) throw("Child on layer " + layerId + " at keyframeIndex " + keyframeIndex + " is not of type flump.Movie!");
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
	
	public var tint(default, set):Int;
	
	private function get_totalFrames() {
		return player.totalFrames;
	}
	
	private function set_tint(pTint:Int):Int {
		for (child in movieChildren) {
			if (Std.is(child, pixi.flump.Sprite)) {
				cast(child, pixi.flump.Sprite).tint = pTint;
			} else if (Std.is(child, pixi.flump.Movie)) {
				cast(child, pixi.flump.Movie).tint = pTint;
			}
		}
		
		return tint = pTint;
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
		layers[layer] = new Container();
		layers[layer].name = layer.name;
		layerLookup[layer.name] = layers[layer];
		addChild(layers[layer]);
	}


	private function getChildPlayer(keyframe:Keyframe):MoviePlayer{
		var movie:Movie = cast movieChildren[keyframe.displayKey];
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


	private function renderFrame(keyframe:Keyframe, x:Float, y:Float, scaleX:Float, scaleY:Float, skewX:Float, skewY:Float, alpha:Float, tintMultiplier:Float, tintColor:UInt):Void{
		/*
		var layer = layers[keyframe.layer];
		var lChild : DisplayObject;
		
		layer.pivot.x = keyframe.pivot.x;
		layer.pivot.y = keyframe.pivot.y;

		if(Std.is(keyframe.symbol, SpriteSymbol)){
			var spriteSymbol:SpriteSymbol = cast keyframe.symbol;
			layer.pivot.x -= spriteSymbol.origin.x;
			layer.pivot.y -= spriteSymbol.origin.y;
		}

		layer.x = x;
		layer.y = y;
		layer.scale.x = scaleX;
		layer.scale.y = scaleY;
		*/
		///////
		///*
		var layer			: Container			= layers[ keyframe.layer];
		var lChild 			: DisplayObject		= null;
		var spriteSymbol	: SpriteSymbol		= null;
		
		layer.x	= x;
		layer.y	= y;
		
		if ( layer.children.length > 0){
			lChild			= layer.getChildAt( 0);
			lChild.scale.x	= scaleX;
			lChild.scale.y	= scaleY;
		}
		
		if ( layer.name != "flipbook"){
			if ( Std.is( keyframe.symbol, SpriteSymbol)){
				spriteSymbol	= cast keyframe.symbol;
				
				layer.pivot.x	= 0;
				layer.pivot.y	= 0;
				
				if ( lChild != null){
					lChild.pivot.x	= keyframe.pivot.x - spriteSymbol.origin.x;
					lChild.pivot.y	= keyframe.pivot.y - spriteSymbol.origin.y;
				}
			}else if ( lChild != null && Std.is( lChild, Container) && cast( lChild, Container).children.length > 0 && cast( lChild, Container).getChildAt( 0).name == "flipbook"){
				lChild.pivot.x	= keyframe.pivot.x;
				lChild.pivot.y	= keyframe.pivot.y;
			}else{
				layer.pivot.x	= keyframe.pivot.x;
				layer.pivot.y	= keyframe.pivot.y;
				
				if ( lChild != null){
					lChild.x	= ( 1 - scaleX) * layer.pivot.x;
					lChild.y	= ( 1 - scaleY) * layer.pivot.y;
				}
			}
		}
		//*/
		///////
		
		layer.skew.x = skewX;
		layer.skew.y = skewY;
		layer.alpha  = alpha;
		
		if (keyframe.layer.refAnimatedTint == null) {
			if (tintMultiplier != 0) {
				keyframe.layer.refAnimatedTint = new AnimateTintFilter(tintColor, tintMultiplier);
				if (layer.filters == null) layer.filters = [keyframe.layer.refAnimatedTint];
			}
		} else if (tintMultiplier == 0) {
			layer.filters.remove(keyframe.layer.refAnimatedTint);
			keyframe.layer.refAnimatedTint = null;
		}
		else keyframe.layer.refAnimatedTint.update(tintColor, tintMultiplier);
		
		if(master){
			//layer.pivot.x /= resolution;
			//layer.pivot.y /= resolution;
			layer.x /= resolution;
			layer.y /= resolution;
			layer.scale.x /= resolution;
			layer.scale.y /= resolution;
		}
	}

	private function setMask(layer:Layer):Void{
		if (layer.mask != null) {
			
			//TODO: Need to create again the mask movie to make it work
			// Is the mask movie not available at this stage of the Movie build ?
			// Where can we call setMask to avoid this inelegant patch ?
			
			var lRect:Rectangle=getLayer(layer.mask).getChildAt(0).getBounds();	
			getLayer(layer.mask).removeChildAt(0);
			var lGraph:Graphics = new Graphics();
			lGraph.beginFill(0);
			lGraph.drawRect(lRect.x, lRect.y, lRect.width, lRect.height);
			lGraph.endFill();
			getLayer(layer.mask).addChild(lGraph);
			layers[layer].mask = lGraph;
			
		}		
	}

	private function labelPassed(label:Label){
		emit("labelPassed", label.name);
	}
	
		private function labelHit(label:Label){
		emit("labelHit", label.name);
	}
	

	override public function destroy(): Void {
		stop();
		onComplete = null;
		for (layer in layers) layer.removeChildren();
		symbol = null;
		player = null;
		super.destroy(true);
	}
	
	/////////////////////////////////////////////////////
	//
	//   custom Data
	//
	/////////////////////////////////////////////////////
	
	public function getBaseClass (): String {
		return symbol.baseClass;
	}
	
	public function getCustomData (): Dynamic {
		return symbol.data;
	}

	public function getLayerCustomData (layerId:String, keyframeIndex:UInt = 0): Dynamic {
		var layer = symbol.getLayer(layerId);
		if(layer == null) throw("Layer " + layerId + " does not exist.");
		var keyframe = symbol.getLayer(layerId).getKeyframeForFrame(keyframeIndex);
		if (keyframe == null) throw("Keyframe does not exist at index " + keyframeIndex);
		return keyframe.data;
	}
}