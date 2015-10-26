package pixi.loaders;

import flump.library.FlumpLibrary;
import pixi.display.FlumpResource;
import js.Browser;
import js.html.Image;
import pixi.core.math.Point;
import pixi.core.math.shapes.Rectangle;
import pixi.core.textures.Texture;
import pixi.core.textures.BaseTexture;
import pixi.core.ticker.Ticker;
import pixi.loaders.Loader;
import pixi.loaders.Resource;

using Reflect;


@:access(pixi.display.FlumpResource)
class FlumpParser{


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


}