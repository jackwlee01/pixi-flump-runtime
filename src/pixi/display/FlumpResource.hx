package pixi.display;

import flump.library.FlumpLibrary;
import flump.library.SpriteSymbol;
import flump.library.MovieSymbol;
import flump.library.Point;
import pixi.core.math.shapes.Rectangle;
import pixi.core.display.DisplayObject;
import pixi.core.sprites.Sprite;
import pixi.core.textures.BaseTexture;
import pixi.core.textures.Texture;
import pixi.core.ticker.Ticker;
import pixi.loaders.Resource;
import pixi.loaders.Loader;


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


	public static function flumpParser(resource:Resource, next:Void->Void){
		if(resource.data == null || resource.isJson == false) return;
		if(!resource.data.hasField("md5") || !resource.data.hasField("movies") || !resource.data.hasField("textureGroups") || !resource.data.hasField("frameRate")) return;
		
		var lib:FlumpLibrary = FlumpLibrary.create(resource.data);
		var textures = new Map<String, Texture>();
		
		var atlasLoader = new Loader();
		atlasLoader.baseUrl = ~/\/(.[^\/]*)$/i.replace(resource.url, "");

		for(atlasSpec in lib.atlases){
			atlasLoader.add(atlasSpec.file, function(atlasResource){
				var atlasTexture = new BaseTexture(atlasResource.data);

				for(textureSpec in atlasSpec.textures){
					var frame = new Rectangle(textureSpec.rect.x, textureSpec.rect.y, textureSpec.rect.width, textureSpec.rect.height);
					var origin = new Point(textureSpec.origin.x, textureSpec.origin.y);
					origin.x = origin.x / frame.width;
					origin.y = origin.y / frame.height;
					textures[textureSpec.symbol] = new Texture(atlasTexture, frame);
				};
			});
		}

		atlasLoader.once("complete", function(loader:Loader){
			var flumpResource = new FlumpResource(lib, textures, resource.name);
			if(resource.name != null) FlumpResource.resources[resource.name] = flumpResource;
			resource.data = flumpResource;
			next();
		});
		atlasLoader.load();
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