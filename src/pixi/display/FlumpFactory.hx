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

	private static var factories = new Map<String, FlumpFactory>();


	public static function get(resourceName:String){
		if(!factories.exists(resourceName)) throw("FlumpFactory for resource name: " + resourceName + " does not exist.");
		return factories[resourceName];
	}


	private function new(library:FlumpLibrary, textures:Map<String, Texture>){
		this.library = library;
		this.textures = textures;
	}


	public function createMovie(id:String):FlumpMovie{
		return new FlumpMovie(library.movies[id], this, true);
	}


	public function createSprite(id:String):Sprite{
		var symbol = library.sprites[id];
		var texture = textures[symbol.texture];
		
		var sprite = new Sprite(texture);
		sprite.pivot.x = symbol.origin.x;
		sprite.pivot.y = symbol.origin.y;
		return sprite;
	}


	public function createDisplayObject(id:String):DisplayObject{
		return library.movies.exists(id)
		? createMovie(id)
		: createSprite(id);
	}


	private function createChildDisplayObject(id:String):DisplayObject{
		return library.movies.exists(id)
		? new FlumpMovie(library.movies[id], this, false)
		: createSprite(id);
	}

}