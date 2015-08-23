package flump;

import flump.FlumpMovie;
import flump.library.MovieSymbol;
import flump.library.Layer;
import flump.library.Keyframe;
import flump.library.Label;
import msignal.Signal;
using Std;


class MoviePlayer{

	private var symbol:MovieSymbol;
	private var movie:FlumpMovie;

	public var speed:Float = 1.0;

	private var lastRenderedKeyframe:Keyframe;
	private var cursor:Float = 0.0;
	

	public function new(symbol:MovieSymbol, movie:FlumpMovie){
		this.symbol = symbol;
		this.movie = movie;
		
		for(layer in symbol.layers){
			movie.createLayer(layer);
		}

		//for(layer in symbol.layers) for(keyframe in layer.keyframes) trace(keyframe);		
	}


	//////////////////////////////////////////////////////////////
	//
	//  Utilities
	//
	//////////////////////////////////////////////////////////////


	private function timeForIndex(index:Float):Float{
		return symbol.library.frameTime * index;
	}


	private function timeForLabel(label:String):Float{
		return symbol.labels.get(label).keyframe.time;
	}


	public function hasLabel(label:String):Bool{
		return symbol.labels.exists("label");
	}


	public function getFrameForLabel(label:String):Int{
		return symbol.labels.get(label).keyframe.index;
	}

	
	private function getKeyframeForTime(layer:Layer, time:Float){
		var keyframe = layer.lastKeyframe;
		while(keyframe.time > time) keyframe = keyframe.prev;
		return keyframe;
	}


	private function getInterpolation(keyframe:Keyframe, time:Float){
		if(keyframe.tweened == false) return 0.0;
		var interped = speed >= 0
		? (time - keyframe.time) / keyframe.duration
		: (keyframe.time - time) / keyframe.duration;

		//trace(time, keyframe.time, keyframe.)

		var ease:Float = keyframe.ease;
		if (ease != 0) {
			var t :Float;
			if (ease < 0) {
				// Ease in
				var inv:Float = 1 - interped;
				t = 1 - inv * inv;
				ease = -ease;
			} else {
				// Ease out
				t = interped * interped;
			}
			interped = ease * t + (1 - ease) * interped;
		}
		return interped;
	}

	/*
	public function advanceTime(dt:Float):Void{
	 	if(isPlaying){
	 		if(true){
	 		//if(forcedTime == false){
		 		cursor += dt;
		 		if(pendingStop && pendingCycle){
		 			if(speed > 0 && cursor > symbol.duration) pendingCycle = false;
		 			else if(speed < 0 && cursor < 0) pendingCycle = false;
		 		}
		 		cursor = cursor % symbol.duration;
		 		if(cursor < 0) cursor += symbol.duration;

		 		if(	(speed > 0 && cursor >= stopPosition) || 
		 			(speed < 0 && cursor <= stopPosition) ){
		 				cursor = stopPosition;
		 				pendingStop = false;
		 				isPlaying = false;
		 		}
		 	}else{
		 		forcedTime = true;
		 	}
	 	}

	 	if(lastRendered != cursor){
	 		lastRendered = cursor;
	 		render(dt);
	 	}
	}
	*/

	//////////////////////////////////////////////////////////////
	//
	//  Rendering
	//
	//////////////////////////////////////////////////////////////

	public function advanceTime(dt:Float):Void{
		cursor += dt * speed;
		cursor = cursor % symbol.duration;
		render(dt);
	}


	public function render(dt:Float){
		movie.startRender();

		for(layer in symbol.layers){
			var keyframe = getKeyframeForTime(layer, cursor);
			
			if(keyframe.isEmpty){
				movie.renderEmptyFrame(keyframe);
			}else{
				var interped = getInterpolation(keyframe, cursor);
				var next = speed >= 0
				? keyframe.next
				: keyframe.prev;

				if(keyframe.symbol.is(MovieSymbol)){
					var child = movie.renderMovieFrame(
						keyframe,
						keyframe.location.x + (next.location.x - keyframe.location.x) * interped,
						keyframe.location.y + (next.location.y - keyframe.location.y) * interped,
						keyframe.scale.x + (next.scale.x - keyframe.scale.x) * interped,
						keyframe.scale.y + (next.scale.y - keyframe.scale.y) * interped,
						keyframe.skew.x + (next.skew.x - keyframe.skew.x) * interped,
						keyframe.skew.y + (next.skew.y - keyframe.skew.y) * interped
					);

					child.advanceTime(dt);
				}else{
					movie.renderFrame(
						keyframe,
						keyframe.location.x + (next.location.x - keyframe.location.x) * interped,
						keyframe.location.y + (next.location.y - keyframe.location.y) * interped,
						keyframe.scale.x + (next.scale.x - keyframe.scale.x) * interped,
						keyframe.scale.y + (next.scale.y - keyframe.scale.y) * interped,
						keyframe.skew.x + (next.skew.x - keyframe.skew.x) * interped,
						keyframe.skew.y + (next.skew.y - keyframe.skew.y) * interped
					);
				}
			}
		}

		movie.completeRender();
	}

}



/*
package flump;

import flump.FlumpMovie;
import flump.library.MovieSymbol;
import flump.library.Layer;
import flump.library.Keyframe;
import flump.library.Label;
import msignal.Signal;
using Std;


class MoviePlayer{

	private var symbol:MovieSymbol;
	private var movie:FlumpMovie;
	private var signals = new Map<Label, Signal0>();

	public var speed(default, set):Float = 1;
	public var currentFrame(get, set):UInt;
	private var isPlaying = true;
	private var cursor(default, set) = 0.0;
	private var forcedTime:Bool = true; // When the cursor is changed, this forces the new frame to play before incrementing the time
	private var lastRendered = -99999.0;

	private var stopPosition(default, set):Float = Math.POSITIVE_INFINITY; // The point in time when the movie stops
	private var pendingCycle:Bool = false; // The movie may need to cycle through before stopping
	private var pendingStop:Bool = false;


	public function new(symbol:MovieSymbol, movie:FlumpMovie){
		this.symbol = symbol;
		this.movie = movie;
		for(layer in symbol.layers) movie.createLayer(layer.name);
		forcedTime = false;
	}


	private function set_cursor(value:Float){
		forcedTime = true;
		return cursor = value;
	}


	private function setCycle(stopPosition){
		if(speed > 0){
			if(stopPosition > cursor) pendingCycle = true;
			else pendingCycle = false;
		}else{
			if(stopPosition < cursor) pendingCycle = true;
			else pendingCycle = false;
		}
	}


	function set_speed(value:Float){
		setCycle(stopPosition);
		return speed = value;
	}


	function set_stopPosition(value:Float){
		setCycle(value);
		return stopPosition = value;
	}


	private function timeForIndex(index:Float):Float{
		return symbol.library.frameTime * index;
	}


	private function timeForLabel(label:String):Float{
		return symbol.labels.get(label).keyframe.time;
	}


	public function hasLabel(label:String):Bool{
		return symbol.labels.exists("label");
	}


	public function loop(){
		isPlaying = true;
		pendingStop = false;
		return this;
	}


	public function getFrameForLabel(label:String):Int{
		return symbol.labels.get(label).keyframe.index;
	}


	public function goToFrame(frame:Int){
		pendingStop = false;
		cursor = timeForIndex(frame);
		return this;
	}


	public function goToLabel(label:String){
		pendingStop = false;
		cursor = timeForLabel(label);
		return this;
	}


	public function playToFrame(frame:Float){
		stopPosition = timeForIndex(frame);
		pendingStop = true;
		isPlaying = true;
		return this;
	}


	public function playToLabel(label:String){
		playToFrame( timeForLabel(label) );
		return this;
	}


	public function playOnce(){
		isPlaying = true;
		stopPosition = symbol.numFrames * symbol.library.frameTime;
		pendingStop = true;
		return this;
	}


	public function playChildrenOnly(){
	 	return this;
	}


	public function advanceTime(dt:Float):Void{
	 	if(isPlaying){
	 		if(true){
	 		//if(forcedTime == false){
		 		cursor += dt;
		 		if(pendingStop && pendingCycle){
		 			if(speed > 0 && cursor > symbol.duration) pendingCycle = false;
		 			else if(speed < 0 && cursor < 0) pendingCycle = false;
		 		}
		 		cursor = cursor % symbol.duration;
		 		if(cursor < 0) cursor += symbol.duration;

		 		if(	(speed > 0 && cursor >= stopPosition) || 
		 			(speed < 0 && cursor <= stopPosition) ){
		 				cursor = stopPosition;
		 				pendingStop = false;
		 				isPlaying = false;
		 		}
		 	}else{
		 		forcedTime = true;
		 	}
	 	}

	 	if(lastRendered != cursor){
	 		lastRendered = cursor;
	 		render(dt);
	 	}
	}


	public function goToNextFrame(keyframe:UInt){
		cursor = timeForIndex(currentFrame + 1);
	}


	public function goToPrevFrame(keyframe:UInt){
		cursor = timeForIndex(currentFrame - 1);
	}


	public function get_currentFrame():UInt{
		return cast Std.int(cursor % symbol.library.frameTime);
	}


	public function set_currentFrame(value:UInt){
		return cast Std.int(cursor = timeForIndex(value));
	}


	private function getKeyframeForTime(layer:Layer, time:Float){
		trace(currentFrame);
		var keyframe = layer.lastKeyframe;
		while(keyframe.time > time) keyframe = keyframe.prev;
		return keyframe;
	}


	private function getInterpolation(keyframe:Keyframe, time:Float){
		var interped = speed >= 0
		? (time - keyframe.time) / symbol.duration
		: (keyframe.time - time) / symbol.duration;

		var ease:Float = keyframe.ease;
		if (ease != 0) {
			var t :Float;
			if (ease < 0) {
				// Ease in
				var inv:Float = 1 - interped;
				t = 1 - inv * inv;
				ease = -ease;
			} else {
				// Ease out
				t = interped * interped;
			}
			interped = ease * t + (1 - ease) * interped;
		}
		return interped;
	}


	public function render(dt:Float){
		movie.startRender();

		for(layer in symbol.layers){
			var keyframe = getKeyframeForTime(layer, cursor);

			if(keyframe.isEmpty){
				movie.renderEmptyFrame(layer.name);
			}else{
				var interped = getInterpolation(keyframe, cursor);
				var next = speed >= 0
				? keyframe.next
				: keyframe.prev;

				if(keyframe.symbol.is(MovieSymbol)){
					var child = movie.renderMovieFrame(
						layer.name,
						keyframe,
						keyframe.symbolId,
						keyframe.location.x + (next.location.x - keyframe.location.x) * interped,
						keyframe.location.y + (next.location.y - keyframe.location.y) * interped,
						keyframe.scale.x + (next.scale.x - keyframe.scale.x) * interped,
						keyframe.scale.y + (next.scale.y - keyframe.scale.y) * interped,
						keyframe.skew.x + (next.skew.x - keyframe.skew.x) * interped,
						keyframe.skew.y + (next.skew.y - keyframe.skew.y) * interped
					);
				}else{
					movie.renderFrame(
						layer.name,
						keyframe,
						keyframe.symbolId,
						keyframe.location.x + (next.location.x - keyframe.location.x) * interped,
						keyframe.location.y + (next.location.y - keyframe.location.y) * interped,
						keyframe.scale.x + (next.scale.x - keyframe.scale.x) * interped,
						keyframe.scale.y + (next.scale.y - keyframe.scale.y) * interped,
						keyframe.skew.x + (next.skew.x - keyframe.skew.x) * interped,
						keyframe.skew.y + (next.skew.y - keyframe.skew.y) * interped
					);
				}
			}
		}

		movie.completeRender();		
	}

}
*/
