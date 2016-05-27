package pixi.flump;

import flump.library.FlumpLibrary;
import flump.library.SpriteSymbol;
import flump.library.MovieSymbol;
import flump.library.Point;
import pixi.core.math.shapes.Rectangle;
import pixi.core.display.DisplayObject;
import pixi.core.textures.BaseTexture;
import pixi.core.textures.Texture;
import pixi.core.ticker.Ticker;
import pixi.loaders.Resource;
import pixi.loaders.Loader;

using Type;


@:access(pixi.flump.Movie)
class Resource{
	
	private var library:FlumpLibrary;
	private var textures:Map<String, Texture>;
	private var resourceId:String;
	private var resolution:Float;

	public static var flumpFactory:Factory;



	private static var resources = new Map<String, Resource>();


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

	
	private static function getResourceForMovie(symbolId:String):Resource{
		for(resource in resources){
			if(resource.library.movies.exists(symbolId)){
				return resource;
			}
		}
		throw("Movie: " + symbolId + "does not exists in any loaded flump resources.");
	}


	private static function getResourceForSprite(symbolId:String):Resource{
		for(resource in resources){
			if(resource.library.sprites.exists(symbolId)){
				return resource;
			}
		}
		throw("Sprite: " + symbolId + " does not exists in any loaded flump resources.");
	}
	


	private function new(library:FlumpLibrary, textures:Map<String, Texture>, resourceId:String, resolution:Float){
		this.library = library;
		this.textures = textures;
		this.resourceId = resourceId;
		this.resolution = resolution;
	}


	private function createMovie(id:String):Movie{
		var movie:Movie;
		if(flumpFactory != null && flumpFactory.displayClassExists(id)){
			movie = flumpFactory.getMovieClass(id).createInstance([]);
		}else{
			movie = new Movie(id, this.resourceId);
		}

		movie.disableAsMaster();
		return movie;
	}


	private function createSprite(id:String):Sprite{
		if(flumpFactory != null && flumpFactory.displayClassExists(id)){
			return flumpFactory.getSpriteClass(id).createInstance([]);
		}else{
			return new Sprite(id, this.resourceId);
		}
	}


	private function createDisplayObject(id:String):DisplayObject {
		var displayObject:DisplayObject = library.movies.exists(id)
		? createMovie(id)
		: createSprite(id);
		
		displayObject.name = id;
		
		return displayObject;
	}

}
