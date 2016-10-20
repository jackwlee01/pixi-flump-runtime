package flump.json;

typedef FlumpJSON = {
	var md5:String;
	var movies:Array<MovieSpec>;
	var textureGroups:Array<TextureGroupSpec>;
	var frameRate: UInt;
}


abstract FlumpPointSpec(Array<Float>){

	public var x(get, never):Float;
	public var y(get, never):Float;

	inline public function get_x():Float{
		return this[0];
	}

	inline public function get_y():Float{
		return this[1];
	}
}


abstract FlumpRectSpec(Array<Float>){

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

typedef MovieSpec = {
	var layers:Array<LayerSpec>;
	var id:ReferenceSpec;
	@:optional var baseClass:String;
	@:optional var data:Dynamic;
}

typedef ReferenceSpec = String;

typedef KeyframeSpec = {
	var pivot:FlumpPointSpec;
	var duration:UInt;
	var loc:FlumpPointSpec;
	var index:UInt;
	var ref:ReferenceSpec;
	var scale:FlumpPointSpec;
	var skew:FlumpPointSpec;
	var ease:Float;
	var tweened:Bool;
	var label:String;
	var alpha:Float;
	@:optional var tint:Array<Dynamic>;
	@:optional var data:Dynamic;
}


typedef TextureSpec = {
	var symbol:ReferenceSpec;
	var rect:FlumpRectSpec;
	var origin:FlumpPointSpec;
	@:optional var baseClass:String;
	@:optional var data:Dynamic;
}


typedef TextureGroupSpec = {
	var atlases:Array<AtlasSpec>;
	var scaleFactor:UInt;
}


typedef AtlasSpec = {
	var file:String;
	var textures:Array<TextureSpec>;
}


typedef LayerSpec = {
	var name:String;
	var keyframes:Array<KeyframeSpec>;
	@:optional var mask:String;
}



