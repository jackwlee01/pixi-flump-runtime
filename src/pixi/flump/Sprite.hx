package pixi.flump;

import flump.library.FlumpLibrary;


@:access(pixi.flump.Resource)
class Sprite extends pixi.core.sprites.Sprite{

	public var symbolId:String;
	public var resourceId:String;
	private var resolution:Float;
	private var data:Dynamic;
	private var baseClass:String;
	

	public function new(symbolId:String, resourceId:String = null){
		this.symbolId = symbolId;
		this.resourceId = resourceId;

		var resource:Resource;
		if(resourceId != null){
			resource = Resource.get(resourceId);
			if(resource == null) throw("Library: " + resourceId + "does has not been loaded.");
		}else{
			resource = Resource.getResourceForSprite(symbolId);
		}
		this.resolution = resource.resolution;

		var symbol = resource.library.sprites[symbolId];
		var texture = resource.textures[symbol.texture];
		super(texture);

		data = symbol.data;
		baseClass = symbol.baseClass;

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
	
	/////////////////////////////////////////////////////
	//
	//   custom Data
	//
	/////////////////////////////////////////////////////
	
	public function getBaseClass (): String {
		return baseClass;
	}
	
	public function getCustomData (): Dynamic {
		return data;
	}
}