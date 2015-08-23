package pixi.display;

import flump.json.FlumpJSON.AtlasSpec;
import flump.library.FlumpLibrary;
import flump.library.MovieSymbol;
import flump.library.SpriteSymbol;
import flump.library.Layer;
import flump.library.Keyframe;
import flump.library.Label;
import js.Browser;
import js.html.Image;
import msignal.Signal;
import pixi.core.math.Point;
import pixi.core.math.shapes.Rectangle;
import pixi.core.textures.Texture;
import pixi.core.textures.BaseTexture;
import pixi.display.FlumpFactory;


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


	public static function loadTextures(lib:FlumpLibrary, path:String, complete:Signal1<FlumpFactory>){
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
			
			/*
			for(texture in atlas.textures){
				var frame = new Rectangle(textureSpec.rect.x, textureSpec.rect.y, textureSpec.rect.width, textureSpec.rect.height);
				var origin = new Point(textureSpec.origin.x, textureSpec.origin.y);
				origin.x = origin.x / frame.width;
				origin.y = origin.y / frame.height;

				var pixiTexture = new Texture(atlas, frame);
			}
			*/
		}

		complete.dispatch(new FlumpFactory(lib, textures));
	}

/*
	private static function loadTextures(lib:FlumpLibrary, path:String, complete:Signal1<FlumpFactory>){
		
		var atlases = new Map<String, BaseTexture>();
		var spriteSymbols = new Map<String, SpriteSymbol>();
		var movieSymbols = new Map<String, MovieSymbol>();
		
		
		var atlasSpecs = new Array<flump.library.FlumpLibrary.Atlas>();

		for(textureGroup in lib.textureGroups){
			for(atlas in textureGroup.atlases){
				atlasSpecs.push(atlas);
			}
		}

		for(spec in atlasSpecs){
			var image = new Image();
			image.src = path + "/" + spec.file;

			var atlas = new BaseTexture(image);
			atlases[spec.file] = atlas;

			for(textureSpec in spec.textures){
				var frame = new Rectangle(textureSpec.rect.x, textureSpec.rect.y, textureSpec.rect.width, textureSpec.rect.height);
				var origin = new Point(textureSpec.origin.x, textureSpec.origin.y);
				origin.x = origin.x / frame.width;
				origin.y = origin.y / frame.height;

				var texture = new Texture(atlas, frame);

				var symbol = new FlumpSpriteSymbol(textureSpec.symbol, origin, texture);
				spriteSymbols[symbol.name] = symbol;
			}
		}


		var pendingSymbolAttachments = new Map<FlumpKeyframe, String>();
		for(movieSpec in lib.movies){
			var symbol = new FlumpMovieSymbol(movieSpec.id);
			for(layerSpec in movieSpec.layers){
				var layer = new FlumpLayer(layerSpec.name);
				layer.movie = symbol;
				var layerLength:Float = 0;
				for(keyframeSpec in layerSpec.keyframes){
					var keyframe = new FlumpKeyframe();
					keyframe.layer = layer;
					keyframe.pivot = keyframeSpec.pivot == null ? new Point(0,0) : new Point( keyframeSpec.pivot.x, keyframeSpec.pivot.y );
					keyframe.duration = keyframeSpec.duration;
					keyframe.location = keyframeSpec.loc == null? new Point(0,0) : new Point( keyframeSpec.loc.x, keyframeSpec.loc.y );
					keyframe.index = keyframeSpec.index;
					keyframe.symbol = null;
					keyframe.scale = keyframeSpec.scale == null ? new Point(1,1) : new Point(keyframeSpec.scale.x, keyframeSpec.scale.y);
					keyframe.skew = keyframeSpec.skew == null ? new Point(0,0) : new Point(keyframeSpec.skew.x, keyframeSpec.skew.y);
					keyframe.ease = keyframeSpec.ease == null ? 0 : keyframeSpec.ease;
					if(keyframeSpec.label != null){
						keyframe.label = new FlumpLabel();
						keyframe.label.keyframe = keyframe;
						keyframe.label.name = keyframeSpec.label;
						symbol.labels.set(keyframe.label.name, keyframe.label);
					}
					layerLength = keyframe.index + keyframe.duration;
					
					pendingSymbolAttachments[keyframe] = keyframeSpec.ref;
					layer.keyframes.push(keyframe);
				}
				layer.length = layerLength;
				symbol.layers.push(layer);
			}
			movieSymbols[symbol.name] = symbol;
		}

		for(keyframe in pendingSymbolAttachments.keys()){
			var symbolId = pendingSymbolAttachments[keyframe];
			keyframe.symbol = spriteSymbols[symbolId] != null ? spriteSymbols[symbolId] : movieSymbols[symbolId];
		}

		var factory = new FlumpFactory(lib, spriteSymbols, movieSymbols);

		complete.dispatch(factory);
	}
*/
}

/*
typedef FlumpPendingSymbolAttachment = {
	var movie:MovieSymbol;
	var keyframe:Keyframe;
	var symbolId:String;
}
*/














