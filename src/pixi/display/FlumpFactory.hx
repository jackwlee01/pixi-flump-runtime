package pixi.display;

import flump.library.FlumpLibrary;
import flump.library.SpriteSymbol;
import flump.library.MovieSymbol;
import pixi.core.display.DisplayObject;
import pixi.core.sprites.Sprite;
import pixi.core.textures.Texture;


class FlumpFactory{
	
	private var library:FlumpLibrary;
	private var textures:Map<String, Texture>;


	public function new(library:FlumpLibrary, textures:Map<String, Texture>){
		this.library = library;
		this.textures = textures;
	}


	public function createMovie(id:String):Movie{
		return new Movie(library.movies[id], this);
	}


	public function createSprite(id:String):Sprite{
		var symbol = library.sprites[id];
		var texture = textures[symbol.texture];
		
		var sprite = new Sprite(texture);
		sprite.anchor.x = symbol.origin.x;
		sprite.anchor.y = symbol.origin.y;
		return sprite;
	}


	public function createDisplayObject(id:String):DisplayObject{
		return library.movies.exists(id)
		? createMovie(id)
		: createSprite(id);
	}

}