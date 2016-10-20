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
	public var alpha:Float;
	public var data:Dynamic;
	public var tintMultiplier:Float;
	public var tintColor:UInt;
	public var next:Keyframe;
	public var prev:Keyframe;
	public var nextNonEmptyKeyframe:Keyframe;
	public var prevNonEmptyKeyframe:Keyframe;
	public var displayKey:DisplayObjectKey;

	public function new(){}

	// Does the time fall inside of the the keyframe frames
	public function timeInside(time:Float):Bool{
		return (this.time <= time) && (this.time + duration) > time;
	}

	// Does the range fit inside of the keyframe frames
	public function rangeInside(from:Float, to:Float):Bool{
		return timeInside(from) && timeInside(to);
	}

	// Does the range intersect with the keyframe frames
	public function rangeIntersect(from:Float, to:Float):Bool{
		return timeInside(from) || timeInside(to);
	}

	// Does the start of the keyframe frames fall inside the range. (Checks for a range that wraps around)
	public function insideRangeStart(from:Float, to:Float):Bool{
		//if(from > to && to == time) return true;
		return from <= to 
			? time > from && time <= to
			: time > from || time <= to;
	}

	// Does the end of the keyframe frames fall inside the range. (Checks for a range that wraps around, and assuming backward playback);
	public function insideRangeEnd(from:Float, to:Float):Bool{
		if(from == to && to == time + duration) return true;
		return from > to
			? to <= time + duration && from > time + duration
			: to <= time + duration || from > time + duration;
	}

}

