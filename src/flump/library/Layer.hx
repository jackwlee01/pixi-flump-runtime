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

}