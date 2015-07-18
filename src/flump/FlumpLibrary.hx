package flump;

abstract FlumpPoint(Array<Float>){

	public var x(get, never):Float;
	public var y(get, never):Float;

	inline public function get_x():Float{
		return this[0];
	}

	inline public function get_y():Float{
		return this[1];
	}
}

abstract FlumpRect(Array<Float>){

	public var x(get, never):Float;
	public var y(get, never):Float;
	public var width(get, never):Float;
	public var height(get, never):Float;

	inline public function get_x():Float{
		return this[0];
	}

	inline public function get_y():Float{
		return this[1];
	}

	inline public function get_width():Float{
		return this[2];
	}

	inline public function get_height():Float{
		return this[3];
	}
}


typedef FlumpLibrary = {
	var md5:String;
	var movies:Array<Movie>;
	var textureGroups:Array<TextureGroup>;
	var frameRate: UInt;
}

typedef Movie = {
	var layers:Array<Layer>;
	var id:Reference;
}

typedef Reference = String;

typedef Keyframe = {
	var pivot:FlumpPoint;
	var duration:UInt;
	var loc:FlumpPoint;
	var index:UInt;
	var ref:Reference;
	var scale:FlumpPoint;
	var skew:FlumpPoint;
	var ease:Float;
}


typedef Texture = {
	var symbol:Reference;
	var rect:FlumpRect;
	var origin:FlumpPoint;
}


typedef TextureGroup = {
	var atlases:Array<Atlas>;
	var scaleFactor:UInt;
}


typedef Atlas = {
	var file:String;
	var textures:Array<Texture>;
}


typedef Layer = {
	var name:String;
	var keyframes:Array<Keyframe>;
}



