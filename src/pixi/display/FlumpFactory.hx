package pixi.display;

import flump.library.FlumpLibrary;
import flump.library.SpriteSymbol;
import flump.library.MovieSymbol;
import pixi.core.display.DisplayObject;
import pixi.core.sprites.Sprite;
import pixi.core.textures.Texture;
import pixi.core.ticker.Ticker;


@:access(pixi.display.FlumpMovie)
class FlumpFactory{
	
	private var library:FlumpLibrary;
	private var textures:Map<String, Texture>;
	private var resourceId:String;

	private static var factories = new Map<String, FlumpFactory>();


	private static function get(resourceName:String){
		if(!factories.exists(resourceName)) throw("FlumpFactory for resource name: " + resourceName + " does not exist.");
		return factories[resourceName];
	}


	private static function getFactoryForMovie(symbolId:String):FlumpFactory{
		for(factory in factories){
			if(factory.library.movies.exists(symbolId)){
				return factory;
			}
		}
		throw("Movie: " + symbolId + "does not exists in any loaded libraries.");
	}


	private static function getFactoryForSprite(symbolId:String):FlumpFactory{
		for(factory in factories){
			if(factory.library.sprites.exists(symbolId)){
				return factory;
			}
		}
		throw("Sprite: " + symbolId + "does not exists in any loaded libraries.");
	}


	private function new(library:FlumpLibrary, textures:Map<String, Texture>, resourceId:String){
		this.library = library;
		this.textures = textures;
		this.resourceId = resourceId;
	}


	private function createMovie(id:String):FlumpMovie{
		var movie = new FlumpMovie(id, this.resourceId);
		movie.disableAsMaster();
		return movie;
	}


	private function createSprite(id:String):Sprite{
		return new FlumpSprite(id, this.resourceId);
	}


	private function createDisplayObject(id:String):DisplayObject{
		return library.movies.exists(id)
		? createMovie(id)
		: createSprite(id);
	}

}