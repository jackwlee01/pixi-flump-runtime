package flump.library;
import flump.filters.AnimateTintFilter;

class Layer{

	public var keyframes = new Array<Keyframe>();
	public var duration:Float;
	public var name:String;
	public var movie:MovieSymbol;
	public var numFrames:UInt;
	public var mask:String;
	public var firstKeyframe:Keyframe;
	public var lastKeyframe:Keyframe;
	public var refAnimatedTint:AnimateTintFilter;

	public function new(name:String){
		this.name = name;
	}


	public function getKeyframeForFrame(index:UInt):Keyframe{
		for(keyframe in keyframes){
			if(keyframe.index <= index && keyframe.index + keyframe.numFrames > index){
				return keyframe;
			}
		}
		return null;
	}
	
	/**
	 * find the keyframe at a time line position
	 * @param	time	position of the time line ; ms ; [ 0 .. movie.duration [
	 * @return	keyframe at this position
	 */
	public function getKeyframeForTime( time : Float) : Keyframe {
		var keyframe = lastKeyframe;
		while(keyframe.time > time/* % movie.duration*/) keyframe = keyframe.prev;
		return keyframe;
	}

}