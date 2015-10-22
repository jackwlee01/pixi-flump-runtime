package flump;

import flump.DisplayObjectKey;
import flump.IFlumpMovie;
import flump.library.MovieSymbol;
import flump.library.Layer;
import flump.library.Keyframe;
import flump.library.Label;
using Std;


class MoviePlayer{

	private var symbol:MovieSymbol;
	private var movie:IFlumpMovie;

	private var elapsed:Float = 0.0; // Total time that has elapsed
	private var previousElapsed:Float = 0.0;
	private var advanced:Float = 0.0; // Time advanced since the last frame

	public var independantTimeline:Bool = true;
	public var independantControl:Bool = false;

	private var state:String;
	private var STATE_PLAYING:String = "playing";
	private var STATE_LOOPING:String = "looping";
	private var STATE_STOPPED:String = "stopped";
		
	private var currentChildrenKey = new Map<Layer, DisplayObjectKey>();
	private var createdChildren = new Map<DisplayObjectKey, Bool>();
	private var childPlayers = new Map<DisplayObjectKey, MoviePlayer>();

	private var labelsToFire = new Array<Label>();
	private var dirty:Bool = false;
	private var fullyGenerated:Bool = false;


	public function new(symbol:MovieSymbol, movie:IFlumpMovie){
		this.symbol = symbol;
		this.movie = movie;
		
		for(layer in symbol.layers){
			movie.createLayer(layer);
		}

		state = STATE_LOOPING;
	}


	public function getDisplayKey(layerId:String, keyframeIndex:UInt = 0):DisplayObjectKey{
		var layer = symbol.getLayer(layerId);
		if(layer == null) throw("Layer " + layerId + " does not exist.");
		var keyframe = layer.getKeyframeForFrame(keyframeIndex);
		if(keyframe == null) throw("Keyframe does not exist at index " + keyframeIndex);
		createChildIfNessessary(keyframe);
		return keyframe.displayKey;
	}


	private function reset(){
		elapsed = 0;
		previousElapsed = 0;
	}


	private var position(get, null):Float = 0.0;
	public function get_position():Float{
		return (elapsed % symbol.duration + symbol.duration) % symbol.duration;
	}


	public var totalFrames (get, null) :UInt;
	private function get_totalFrames(){
		return symbol.totalFrames;
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
		if(!labelExists(label)) throw("Symbol " + symbol.name + " does not have label " + label + "." );
		currentFrame = getLabelFrame(label);
		return this;
	}


	public function goToFrame(frame:Int){
		currentFrame = frame;
		return this;
	}


	public function goToPosition(time:Float){
		elapsed = time;
		previousElapsed = time;
		clearLabels();
		fireLabels();
		return this;
	}


	public var playing(get, null):Bool;
	private function get_playing(){
		return state == STATE_PLAYING;
	}


	public var looping(get, null):Bool;
	private function get_looping(){
		return state == STATE_LOOPING;
	}


	public var stopped(get, null):Bool;
	private function get_stopped(){
		return state == STATE_STOPPED;
	}


	public function getLabelFrame(label:String):UInt{
		if(!labelExists(label)) throw("Symbol " + symbol.name + " does not have label " + label + "." );
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


	public function labelExists(label:String):Bool{
		return symbol.labels.exists("label");
	}


	public function advanceTime(ms:Float):Void{
		if(state != STATE_STOPPED){
			elapsed += ms;
			while(elapsed < 0){
				elapsed += symbol.duration;
				previousElapsed += symbol.duration;
			}
		}
		advanced += ms;

		if(state != STATE_STOPPED) fireLabels();
		render();
	}


	private function clearLabels(){
		while(labelsToFire.length > 0) labelsToFire.pop();
	}


	private function fireLabels(){
		if(symbol.firstLabel == null) return;
		if(previousElapsed > elapsed) return;
		
		
		var label:Label = previousElapsed <= elapsed
			? symbol.firstLabel
			: symbol.lastLabel;
		
		var checking = true;
		while(checking){
			if(label.keyframe.time > previousElapsed%symbol.duration){
				checking = false;
				//trace(label.keyframe.index);
				//label = label.prev;
			}else if(label.next.keyframe.index <= label.keyframe.index){
				checking = false;
				label = label.next;
			}else{
				label = label.next;
			}
		}
		


		var firstChecked = label;

		while(label != null){
			var checkFrom = previousElapsed % symbol.duration;
			var checkTo = elapsed % symbol.duration;
			if(label.keyframe.insideRangeStart(checkFrom, checkTo)){
				labelsToFire.push(label);
				//trace("pushed: " + label.keyframe.index + " || " + (checkFrom/symbol.library.frameTime) + " : " + (checkTo/symbol.library.frameTime));
			}

			label = label.next;
			if(label == firstChecked) label = null;
		}
		

		while(labelsToFire.length > 0){
			movie.labelPassed(labelsToFire.shift());
		}

	}



	private function render():Void{
		if(state == STATE_PLAYING){
			if(position < 0){
				elapsed = 0;
				stop();
				movie.onAnimationComplete();
			}else if(position > symbol.duration - symbol.library.frameTime){
				elapsed = symbol.duration - symbol.library.frameTime;
				stop();
				movie.onAnimationComplete();
			}
		}

		while(position < 0) position += symbol.duration;
		
		for(layer in symbol.layers){
			var keyframe = layer.getKeyframeForTime(position);

			if(keyframe.isEmpty == true){
				removeChildIfNessessary(keyframe);
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


				if(currentChildrenKey.get(layer) != keyframe.displayKey){
					createChildIfNessessary(keyframe);
					removeChildIfNessessary(keyframe);
					addChildIfNessessary(keyframe);
				}

				if(keyframe.symbol.is(MovieSymbol)){
					var childMovie = movie.getChildPlayer(keyframe);

					if(childMovie.independantTimeline){
						childMovie.advanceTime(advanced);
						childMovie.render();
					}else{
						childMovie.elapsed = position;
						childMovie.render();
					}
				}
			}
		}
		advanced = 0;
		previousElapsed = elapsed;
	}


	private function createChildIfNessessary(keyframe:Keyframe){
		if(keyframe.isEmpty) return;
		if(createdChildren.exists(keyframe.displayKey) == false){
			movie.createFlumpChild(keyframe.displayKey);
			createdChildren[keyframe.displayKey] = true;
		}
	}


	private function removeChildIfNessessary(keyframe:Keyframe){
		if(currentChildrenKey.exists(keyframe.layer)){
			movie.removeFlumpChild(keyframe.layer, keyframe.displayKey);
			currentChildrenKey.remove(keyframe.layer);
		}
	}


	private function addChildIfNessessary(keyframe:Keyframe){
		if(keyframe.isEmpty) return;
		currentChildrenKey[keyframe.layer] = keyframe.displayKey;
		movie.addFlumpChild(keyframe.layer, keyframe.displayKey);
	}


	
	//////////////////////////////////////////////////////////////
	//
	//  Utilities
	//
	//////////////////////////////////////////////////////////////

	private function setState(state:String){
		this.state = state;

		for(layer in symbol.layers){
			var keyframe = layer.getKeyframeForTime(position);
			createChildIfNessessary(keyframe);

			if(keyframe.symbol.is(MovieSymbol)){
				var childMovie = movie.getChildPlayer(keyframe);
				if(childMovie.independantControl == false){
					childMovie.setState(state);
				}
			}
		}
	}


	private function timeForLabel(label:String):Float{
		return symbol.labels[label].keyframe.time;
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


}

