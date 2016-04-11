package pixi.display;

import flump.library.FlumpLibrary;
import pixi.core.sprites.Sprite;


@:access(pixi.display.FlumpResource)
class FlumpSprite extends Sprite{

	public var symbolId:String;
	public var resourceId:String;
	private var resolution:Float;
	

	public function new(symbolId:String, resourceId:String = null){
		this.symbolId = symbolId;
		this.resourceId = resourceId;

		var resource:FlumpResource;
		if(resourceId != null){
			resource = FlumpResource.get(resourceId);
			if(resource == null) throw("Library: " + resourceId + "does has not been loaded.");
		}else{
			resource = FlumpResource.getResourceForSprite(symbolId);
		}
		this.resolution = resource.resolution;

		var symbol = resource.library.sprites[symbolId];
		var texture = resource.textures[symbol.texture];
		super(texture);


		anchor.x = symbol.origin.x / texture.width;
		anchor.y = symbol.origin.y / texture.height;

		//pivot.x = symbol.origin.x;
		//pivot.y = symbol.origin.y;
	}

	public var resX(get, set):Float;
	public function get_resX():Float{
		return x / resolution;
	}
	public function set_resX(value:Float):Float{
		x = value * resolution;
		return value;
	}

	public var resY(get, set):Float;
	public function get_resY():Float{
		return y / resolution;
	}
	public function set_resY(value:Float):Float{
		y = value * resolution;
		return value;
	}

	public var resScaleX(get, set):Float;
	public function get_resScaleX():Float{
		return scale.x / resolution;
	}
	public function set_resScaleX(value:Float):Float{
		scale.x = value * resolution;
		return value;
	}

	public var resScaleY(get, set):Float;
	public function get_resScaleY():Float{
		return scale.y / resolution;
	}
	public function set_resScaleY(value:Float):Float{
		scale.y = value * resolution;
		return value;
	}


}