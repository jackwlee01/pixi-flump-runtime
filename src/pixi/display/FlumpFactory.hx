package pixi.display;

import flump.FlumpLibrary;
import flump.FlumpMovieSymbol;
import flump.FlumpSpriteSymbol;
import pixi.core.display.DisplayObject;
import pixi.core.sprites.Sprite;
import pixi.core.textures.Texture;
import pixi.loaders.ResourceLoader;



class FlumpFactory{

	private var library:FlumpLibrary;
	public var spriteSymbols:Map<String, FlumpSpriteSymbol>;
	public var movieSymbols:Map<String, FlumpMovieSymbol>;



	public function new(library:FlumpLibrary, spriteSymbols:Map<String, FlumpSpriteSymbol>, movieSymbols:Map<String, FlumpMovieSymbol>){
		this.library = library;
		this.spriteSymbols = spriteSymbols;
		this.movieSymbols = movieSymbols;

		/*
		var assetsToLoader = [ "SpriteSheet.json"];
	
		loader = new PIXI.AssetLoader(assetsToLoader);
		loader.onComplete = onAssetsLoaded
		*/

		/*
		var loader:ResourceLoader = new ResourceLoader();
		loader.add("spriteAtlas", "./mascot/atlas0.atlas");

		loader.load(function(){
			trace("ANother loaded");
		});
*/

	}



	public function createMovie(id:String):FlumpMovie{
		return new FlumpMovie( movieSymbols.get(id), this );
	}


	public function createSprite(id:String):Sprite{
		var symbol = spriteSymbols.get(id);
		var sprite = new Sprite(symbol.texture);
		sprite.anchor.x = symbol.origin.x;
		sprite.anchor.y = symbol.origin.y;
		return sprite;
	}


	public function createDisplayObject(id:String):DisplayObject{
		return spriteSymbols[id] != null
			? createSprite(id)
			: createMovie(id);
	}

}