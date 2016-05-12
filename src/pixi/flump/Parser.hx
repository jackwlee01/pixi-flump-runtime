package pixi.flump;

import flump.library.FlumpLibrary;
import pixi.core.math.Point;
import pixi.core.math.shapes.Rectangle;
import pixi.core.textures.Texture;
import pixi.core.textures.BaseTexture;
import pixi.loaders.Loader;
import pixi.loaders.Resource;

using Reflect;

@:access(pixi.flump.Resource)
class Parser{


	public static function parse(resolution:Float, ?loadFromCache:Bool = true){
		return function(resource:Resource, next:Void->Void){
			if(resource.data == null || resource.isJson == false) return;
			if(!resource.data.hasField("md5") || !resource.data.hasField("movies") || !resource.data.hasField("textureGroups") || !resource.data.hasField("frameRate")) return;
			
			var lib:FlumpLibrary = FlumpLibrary.create(resource.data, resolution);
			var textures = new Map<String, Texture>();
			
			var atlasLoader = new Loader();
			atlasLoader.baseUrl = ~/\/(.[^\/]*)$/i.replace(resource.url, "");

			for(atlasSpec in lib.atlases){
				atlasSpec.file += loadFromCache ? '' : "?" + Date.now().getTime();
				atlasLoader.add(atlasSpec.file, function(atlasResource){
					var atlasTexture = new BaseTexture(atlasResource.data);
					atlasTexture.resolution = resolution;

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
				var flumpResource = new pixi.flump.Resource(lib, textures, resource.name, resolution);
				if(resource.name != null) pixi.flump.Resource.resources[resource.name] = flumpResource;
				resource.data = flumpResource;
				next();
			});
			atlasLoader.load();
		}
	}


}