package flump;

import flump.DisplayObjectKey;
import flump.IFlumpMovie;
import flump.library.Keyframe;
import flump.library.Label;
import flump.library.Layer;
import flump.library.MovieSymbol;
using Std;


class MoviePlayer{

	private var symbol:MovieSymbol;
	private var movie:IFlumpMovie;

	private var elapsed:Float = 0.0; // Total time that has elapsed
	private var previousElapsed:Float = 0.0;
	private var advanced:Float = 0.0; // Time advanced since the last frame
	
	/** previous render "position" value ; -1 means no previous render */
	var prevPosition							: Float									= -1;
	
	public var independantTimeline:Bool = true;
	public var independantControl:Bool = true;

	private var state:String;
	private var STATE_PLAYING:String = "playing";
	private var STATE_LOOPING:String = "looping";
	private var STATE_STOPPED:String = "stopped";
		
	private var currentChildrenKey = new Map<Layer, DisplayObjectKey>();
	private var createdChildren = new Map<DisplayObjectKey, Bool>();
	private var childPlayers = new Map<DisplayObjectKey, MoviePlayer>();

	private var labelsToFire = new Array<Label>();
	private var changed:Int = 0;
	//private var labelsToIgnore = new ObjectMap<Label, Label>();
	private var dirty:Bool = false;
	private var fullyGenerated:Bool = false;

	private var resolution:Float;


	public function new(symbol:MovieSymbol, movie:IFlumpMovie, resolution:Float){
		this.symbol = symbol;
		this.movie = movie;
		this.resolution = resolution;

		for(layer in symbol.layers){
			movie.createLayer(layer);
		}

		state = STATE_LOOPING;
		advanceTime(0);
		for (layer in symbol.layers) movie.setMask(layer);
	}

	public var labels(get, null):Iterator<Label>;
	public function get_labels():Iterator<Label>{
		return symbol.labels.iterator();
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
		prevPosition = -1;
	}
	
	private var position(get, null):Float = 0.0;
	public function get_position():Float{
		var lModPos	: Float	= ( elapsed % symbol.duration + symbol.duration) % symbol.duration;
		var lEndPos	: Float;
		
		if ( state == STATE_PLAYING){
			lEndPos = symbol.duration - symbol.library.frameTime;
			
			if ( elapsed >= lEndPos) return lEndPos;
			else return lModPos;
		}else return lModPos;
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
		fireHitFrames(getLabelFrame(label));
		//ignoreCurrentLabels();
		return this;
	}


	public function goToFrame(frame:Int){
		currentFrame = frame;
		fireHitFrames(frame);
		return this;
	}


	private function fireHitFrames(frame:Int){
		changed++;
		var current = changed;
		var time = frame * symbol.library.frameTime;

		for(layer in symbol.layers){
			for(kf in layer.keyframes){
				if(current != changed) return;
				if(kf.label != null){
					if(kf.timeInside(time)) movie.labelHit(kf.label);
				}
			}
		}
	}


	public function goToPosition(time:Float){
		elapsed = time;
		previousElapsed = time;
		clearLabels();
		//ignoreCurrentLabels();
		//fireLabels();
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
	
	/*
	private function ignoreCurrentLabels(){
		for(layer in symbol.layers){
			var kf = layer.getKeyframeForFrame(currentFrame);
			if(kf != null){
				if(kf.label != null){
					labelsToIgnore.set(kf.label, kf.label);
				}
			}
		}
	}
	*/


	public var currentFrame(get, set):Int;
	private function get_currentFrame():Int{
		return Std.int(position / symbol.library.frameTime);
	}
	private function set_currentFrame(value:Int):Int{
		goToPosition( symbol.library.frameTime * value);
		return value;
	}


	public function labelExists(label:String):Bool{
		return symbol.labels.exists(label);
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
			if(label.keyframe.insideRangeStart(checkFrom, checkTo) && state != STATE_STOPPED){
				labelsToFire.push(label);
			}

			label = label.next;
			if(label == firstChecked) label = null;
		}

		while(labelsToFire.length > 0){
			var label = labelsToFire.shift();
			movie.labelPassed(label);
		}

		/*
		for(key in labelsToIgnore.keys()){
			var label = labelsToIgnore.get(key);
			labelsToIgnore.remove(key);
			trace("Label fire: " + label.name);
			movie.labelHit(label);
		}
		*/
	}



	private function render():Void{
		var lIsUpdate	: Bool		= true;
		var next		: Keyframe	= null;
		var interped	: Float		= -1;
		var lColor		:Int		= -1;// AnimateTint
		
		if (state == STATE_PLAYING){
			// "position" could not be negative, this shouldn't occures
			/*if(position < 0){
				elapsed = 0;
				stop();
				movie.onAnimationComplete();
			}else */if(position >= symbol.duration - symbol.library.frameTime){
				elapsed = symbol.duration - symbol.library.frameTime;
				stop();
				movie.onAnimationComplete();
			}
		}
		
		// there's no setter for "position", is there ? also, "position" calculation provides only positive values, from "elapsed" modulo
		//while(position < 0) position += symbol.duration;
		
		if ( position != prevPosition && ( prevPosition < 0 || totalFrames > 1)) prevPosition = position;
		else lIsUpdate = false;
		
		for (layer in symbol.layers){
			var keyframe	: Keyframe	= layer.getKeyframeForTime(position);

			if(keyframe.isEmpty == true){
				removeChildIfNessessary(keyframe);
			}else if(keyframe.isEmpty == false){
				if ( lIsUpdate){
					interped	= getInterpolation( keyframe, position);
					next		= keyframe.next;
					
					if( next.isEmpty) next = keyframe;// NASTY! FIX THIS!!
					
					if (keyframe.tintColor != next.tintColor) {
						
						var lPrevColor:Int = keyframe.tintColor;
						var lNextColor:Int = next.tintColor;
						
						var lPrevR:Int = (lPrevColor >> 16) & 0xFF;
						var lPrevG:Int = (lPrevColor >> 8) & 0xFF;
						var lPrevB:Int = lPrevColor & 0xFF;
						
						var lNextR:Int = (lNextColor >> 16) & 0xFF;
						var lNextG:Int = (lNextColor >> 8) & 0xFF;
						var lNextB:Int = lNextColor & 0xFF;
						
						lColor = Math.round(lPrevR + (lNextR - lPrevR) * interped) << 16 | Math.round(lPrevG + (lNextG - lPrevG) * interped) << 8 | Math.round(lPrevB + (lNextB - lPrevB) * interped);
						
					} else lColor = keyframe.tintColor;
					

					if(currentChildrenKey.get(layer) != keyframe.displayKey){
						createChildIfNessessary(keyframe);
						removeChildIfNessessary(keyframe);
						addChildIfNessessary(keyframe);
					}
				}

				if(keyframe.symbol.is(MovieSymbol)){
					var childMovie = movie.getChildPlayer(keyframe);

					if(childMovie.independantTimeline){
						childMovie.advanceTime(advanced);
						// no need ? "render" call already included at the end of "advanceTime" : childMovie.render();
					}else{
						childMovie.elapsed = position;
						childMovie.render();
					}
				}
				
				if ( lIsUpdate){
					movie.renderFrame(
						keyframe,
						(keyframe.location.x + (next.location.x - keyframe.location.x) * interped),
						(keyframe.location.y + (next.location.y - keyframe.location.y) * interped),
						(keyframe.scale.x + (next.scale.x - keyframe.scale.x) * interped),
						(keyframe.scale.y + (next.scale.y - keyframe.scale.y) * interped),
						keyframe.skew.x + (next.skew.x - keyframe.skew.x) * interped,
						keyframe.skew.y + (next.skew.y - keyframe.skew.y) * interped,
						keyframe.alpha + (next.alpha - keyframe.alpha) * interped,
						keyframe.tintMultiplier + (next.tintMultiplier - keyframe.tintMultiplier) * interped,
						lColor
					);
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
		advanceTime(0);
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

