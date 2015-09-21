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

	private var elapsed:Float = 0.0; // Total time that has elapsed
	private var advanced:Float = 0.0; // Time advanced since the last frame

	public var independantTimeline:Bool = true;
	public var independantControl:Bool = false;
	
	private var state:String;
	private var STATE_PLAYING:String = "playing";
	private var STATE_LOOPING:String = "looping";
	private var STATE_STOPPED:String = "stopped";
	

	public function new(symbol:MovieSymbol, movie:FlumpMovie){
		this.symbol = symbol;
		this.movie = movie;
		
		for(layer in symbol.layers) movie.createLayer(layer);
		state = STATE_LOOPING;
	}


	private var position(get, null):Float = 0.0;
	public function get_position():Float{
		return (elapsed % symbol.duration + symbol.duration) % symbol.duration;
	}


	public var numFrames (get, null) :UInt;
	private function get_numFrames(){
		return symbol.numFrames;
	}


	public function play(){
		setState(STATE_PLAYING);
		return this;
	}


	public function loop(){
		setState(STATE_LOOPING);
		return this;
	}


	public function stop(){
		setState(STATE_STOPPED);
		return this;
	}


	public function goToLabel(label:String){
		if(!hasLabel(label)) throw("Symbol " + symbol.name + " does not have label " + label + "." );
		currentFrame = getLabelFrame(label);
		return this;
	}


	public function goToFrame(frame:Int){
		currentFrame = frame;
		return this;
	}


	public function goToPosition(time:Float){
		elapsed = time;
		return this;
	}



	public var isPlaying(get, null):Bool;
	private function get_isPlaying(){
		return state == STATE_PLAYING;
	}


	public var isLooping(get, null):Bool;
	private function get_isLooping(){
		return state == STATE_LOOPING;
	}


	public var isStopped(get, null):Bool;
	private function get_isStopped(){
		return state == STATE_STOPPED;
	}


	public function getLabelFrame(label:String):UInt{
		if(!hasLabel(label)) throw("Symbol " + symbol.name + " does not have label " + label + "." );
		return symbol.labels.get(label).keyframe.index;
	}
	

	public var currentFrame(get, set):Int;
	private function get_currentFrame():Int{
		return Std.int(position / symbol.library.frameTime);
	}
	private function set_currentFrame(value:Int):Int{
		goToPosition( symbol.library.frameTime * value);
		return value;
	}


	public function hasLabel(label:String):Bool{
		return symbol.labels.exists("label");
	}



	//////////////////////////////////////////////////////////////
	//
	//  Utilities
	//
	//////////////////////////////////////////////////////////////

	private function setState(state:String){
		this.state = state;

		for(layer in symbol.layers){
			var keyframe = getKeyframeForTime(layer, position);
			if(keyframe.symbol.is(MovieSymbol)){
				var childMovie = movie.getChildMovie(keyframe);
				if(childMovie.independantControl == false){
					childMovie.setState(state);
				}
			}
		}
	}

	
	private function timeForLabel(label:String):Float{
		return symbol.labels.get(label).keyframe.time;
	}


	private function getKeyframeForTime(layer:Layer, time:Float){
		var keyframe = layer.lastKeyframe;
		while(keyframe.time > time) keyframe = keyframe.prev;
		return keyframe;
	}


	private function getInterpolation(keyframe:Keyframe, time:Float){
		if(keyframe.tweened == false) return 0.0;
		
		var interped = (time - keyframe.time) / keyframe.duration;
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

	public function advanceTime(dt:Float){
		if(state != STATE_STOPPED) elapsed += dt;
		advanced += dt;
		render();
	}


	public function render(){
		if(state == STATE_PLAYING){
			if(position < 0){
				elapsed = 0;
				stop();
			}else if(position > symbol.duration - symbol.library.frameTime){
				elapsed = symbol.duration - symbol.library.frameTime;
				stop();
			}
		}


		while(position < 0) position += symbol.duration;
		
		movie.startRender();

		for(layer in symbol.layers){
			var keyframe = getKeyframeForTime(layer, position);

			if(keyframe.isEmpty == true){
				movie.renderEmptyFrame(keyframe);
			}else if(keyframe.isEmpty == false){
				var interped = getInterpolation(keyframe, position);
				var next = keyframe.next;
				if(next.isEmpty) next = keyframe; // NASTY! FIX THIS!!

				movie.renderFrame(
					keyframe,
					keyframe.location.x + (next.location.x - keyframe.location.x) * interped,
					keyframe.location.y + (next.location.y - keyframe.location.y) * interped,
					keyframe.scale.x + (next.scale.x - keyframe.scale.x) * interped,
					keyframe.scale.y + (next.scale.y - keyframe.scale.y) * interped,
					keyframe.skew.x + (next.skew.x - keyframe.skew.x) * interped,
					keyframe.skew.y + (next.skew.y - keyframe.skew.y) * interped
				);

				if(keyframe.symbol.is(MovieSymbol)){
					var childMovie = movie.getChildMovie(keyframe);


					if(childMovie.independantTimeline){
						//trace(elapsed, lastRender);
						childMovie.advanceTime(advanced);
						childMovie.render();
					}else{
						childMovie.elapsed = position;
						childMovie.render();
					}
					
					/*
					if(childMovie.isIndependant == false){
						childMovie.elapsed = elapsed;
						childMovie.render(dt);
					}else{
						childMovie.advanceTime(dt * speed);
					}
					*/
				}
			}
		}
		advanced = 0;
		movie.completeRender();
	}

}

