package pixi.display;

import flump.library.FlumpLibrary;
import pixi.core.sprites.Sprite;


@:access(pixi.display.FlumpResource)
class FlumpSprite extends Sprite{

	public var symbolId:String;
	public var resourceId:String;
	

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

		var symbol = resource.library.sprites[symbolId];
		var texture = resource.textures[symbol.texture];
		super(texture);

		pivot.x = symbol.origin.x;
		pivot.y = symbol.origin.y;
	}


}