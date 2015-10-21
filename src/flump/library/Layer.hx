package flump.library;

class Layer{

	public var keyframes = new Array<Keyframe>();
	public var duration:Float;
	public var name:String;
	public var movie:MovieSymbol;
	public var numFrames:UInt;

	public var firstKeyframe:Keyframe;
	public var lastKeyframe:Keyframe;


	public function new(name:String){
		this.name = name;
	}


	public function getKeyframeForFrame(index:UInt):Keyframe{
		for(keyframe in keyframes) if(keyframe.index == index) return keyframe;
		return null;
	}


	public function getKeyframeForTime(time:Float){
		var keyframe = lastKeyframe;
		while(keyframe.time > time % movie.duration) keyframe = keyframe.prev;
		return keyframe;
	}

}