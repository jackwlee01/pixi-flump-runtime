package flump;

import pixi.core.math.Point;
import pixi.core.textures.Texture;


class FlumpSpriteSymbol extends FlumpSymbol{

	public var texture:Texture;
	public var origin:Point;


	public function new(name:String, origin:Point, texture:Texture){
		super(name);
		this.texture = texture;
		this.origin = origin;
	}

}