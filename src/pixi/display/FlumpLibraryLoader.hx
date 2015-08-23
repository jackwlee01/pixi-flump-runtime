package pixi.display;

import flump.library.FlumpLibrary;
import pixi.display.FlumpFactory;
import js.Browser;
import js.html.Image;
import msignal.Signal;
import pixi.core.math.Point;
import pixi.core.math.shapes.Rectangle;
import pixi.core.textures.Texture;
import pixi.core.textures.BaseTexture;


class FlumpLibraryLoader{


	public static function load(path:String){
		var complete = new Signal1<FlumpFactory>();
		
		var h = new haxe.Http(path + "/library.json");
		trace(path +  "/library.json");
		h.onStatus = function(x){
		};

		h.onData = function(data){
			var lib:FlumpLibrary = FlumpLibrary.parseJSON(data);
			loadTextures(lib, path, complete);
		}

		h.request(false);

		return complete;
	}


	private static function loadTextures(lib:FlumpLibrary, path:String, complete:Signal1<FlumpFactory>){
		var textures = new Map<String, Texture>();
		for(atlas in lib.atlases){
			var image = new Image();
			image.src = path + "/" + atlas.file;
		
			var atlasTexture = new BaseTexture(image);

			for(textureSpec in atlas.textures){
				var frame = new Rectangle(textureSpec.rect.x, textureSpec.rect.y, textureSpec.rect.width, textureSpec.rect.height);
				var origin = new Point(textureSpec.origin.x, textureSpec.origin.y);
				origin.x = origin.x / frame.width;
				origin.y = origin.y / frame.height;

				var texture = new Texture(atlasTexture, frame);
				textures[textureSpec.symbol] = texture;
			}
		
		}

		complete.dispatch(new FlumpFactory(lib, textures));
	}

}
