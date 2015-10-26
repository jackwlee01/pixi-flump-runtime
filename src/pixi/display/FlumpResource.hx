package pixi.display;

import flump.library.FlumpLibrary;
import flump.library.SpriteSymbol;
import flump.library.MovieSymbol;
import pixi.core.display.DisplayObject;
import pixi.core.sprites.Sprite;
import pixi.core.textures.Texture;
import pixi.core.ticker.Ticker;


@:access(pixi.display.FlumpMovie)
class FlumpResource{
	
	private var library:FlumpLibrary;
	private var textures:Map<String, Texture>;
	private var resourceId:String;

	private static var resources = new Map<String, FlumpResource>();


	public static function exists(resourceName:String){
		return resources.exists(resourceName);
	}


	public static function destroy(resourceName:String){
		if(resources.exists(resourceName) == false) throw("Cannot destroy FlumpResource: " + resourceName + " as it does not exist.");
		
		var resource = resources[resourceName];
		for(texture in resource.textures)texture.destroy();
		resource.library = null;
		resources.remove(resourceName);
	}


	private static function get(resourceName:String){
		if(!resources.exists(resourceName)) throw("Flump resource: " + resourceName + " does not exist.");
		return resources[resourceName];
	}

	
	private static function getResourceForMovie(symbolId:String):FlumpResource{
		for(resource in resources){
			if(resource.library.movies.exists(symbolId)){
				return resource;
			}
		}
		throw("Movie: " + symbolId + "does not exists in any loaded flump resources.");
	}


	private static function getResourceForSprite(symbolId:String):FlumpResource{
		for(resource in resources){
			if(resource.library.sprites.exists(symbolId)){
				return resource;
			}
		}
		throw("Sprite: " + symbolId + "does not exists in any loaded flump resources.");
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