package flump.library;


class Keyframe{

	public var layer:Layer;
	public var symbolId:String;
	public var pivot:Point;
	
	public var location:Point;
	public var tweened:Bool;

	public var index:UInt;
	public var numFrames:UInt;

	public var time:Float;
	public var duration:Float;
	
	public var symbol:Symbol;
	public var scale:Point;
	public var skew:Point;
	public var ease:Float;
	public var label:Label;
	public var isEmpty:Bool;

	public var next:Keyframe;
	public var prev:Keyframe;
	public var nextNonEmptyKeyframe:Keyframe;
	public var prevNonEmptyKeyframe:Keyframe;
	public var displayKey:DisplayObjectKey;

	public function new(){}

}

