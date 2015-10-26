package pixi.display;

import flump.library.FlumpLibrary;
import pixi.core.sprites.Sprite;


@:access(pixi.display.FlumpFactory)
class FlumpSprite extends Sprite{

	public var symbolId:String;
	public var resourceId:String;
	

	public function new(symbolId:String, resourceId:String = null){
		this.symbolId = symbolId;
		this.resourceId = resourceId;

		var factory:FlumpFactory;
		if(resourceId != null){
			factory = FlumpFactory.get(resourceId);
			if(factory == null) throw("Library: " + resourceId + "does has not been loaded.");
		}else{
			factory = FlumpFactory.getFactoryForSprite(symbolId);
		}

		var symbol = factory.library.sprites[symbolId];
		var texture = factory.textures[symbol.texture];
		super(texture);

		pivot.x = symbol.origin.x;
		pivot.y = symbol.origin.y;
	}


}