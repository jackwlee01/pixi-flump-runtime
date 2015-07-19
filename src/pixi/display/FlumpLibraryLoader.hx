package pixi.display;

import flump.FlumpLibrary;
import flump.FlumpMovieSymbol;
import flump.FlumpSpriteSymbol;
import flump.FlumpLayer;
import flump.FlumpKeyframe;
import js.Browser;
import js.html.Image;
import msignal.Signal;
import pixi.core.math.Point;
import pixi.core.math.shapes.Rectangle;
import pixi.core.textures.Texture;
import pixi.core.textures.BaseTexture;


class FlumpLibraryLoader{


	public static function load(path:String){
		#if js
		#else
			throw("This is only a javascript library!");
		#end


		var complete = new Signal1<FlumpFactory>();
		trace("Loading library");

		var h = new haxe.Http(path + "/library.json");
		h.onStatus = function(x){
			trace(x);
		};
		h.onData = function(data){
			var lib:FlumpLibrary = cast haxe.Json.parse(data);
			loadTextures(lib, path, complete);
		}
		h.request(false);

		return complete;		
	}


	private static function loadTextures(lib:FlumpLibrary, path:String, complete:Signal1<FlumpFactory>){
		
		var atlases = new Map<String, BaseTexture>();
		var spriteSymbols = new Map<String, FlumpSpriteSymbol>();
		var movieSymbols = new Map<String, FlumpMovieSymbol>();
		
		
		var atlasSpecs = new Array<flump.FlumpLibrary.Atlas>();

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
				var layerLength:Float = 0;
				for(keyframeSpec in layerSpec.keyframes){
					var keyframe = new FlumpKeyframe();
					keyframe.pivot = keyframeSpec.pivot == null ? new Point(0,0) : new Point( keyframeSpec.pivot.x, keyframeSpec.pivot.y );
					keyframe.duration = keyframeSpec.duration;
					keyframe.location = keyframeSpec.loc == null? new Point(0,0) : new Point( keyframeSpec.loc.x, keyframeSpec.loc.y );
					keyframe.index = keyframeSpec.index;
					keyframe.symbol = null;
					keyframe.scale = keyframeSpec.scale == null ? new Point(1,1) : new Point(keyframeSpec.scale.x, keyframeSpec.scale.y);
					keyframe.skew = keyframeSpec.skew == null ? new Point(0,0) : new Point(keyframeSpec.skew.x, keyframeSpec.skew.y);
					keyframe.ease = keyframeSpec.ease == null ? 0 : keyframeSpec.ease;
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
		

		/*
		function loadNext(){
			if(atlasSpecs.length == 0){
				var factory = new FlumpFactory(lib, path);
				complete.dispatch(factory);
			}else{
				var spec = atlasSpecs.shift();
				var h = new haxe.Http(path + spec.file);
				h.onStatus = function(x){
					trace(x);
				}
				h.onData = function(x){

				}
			}
		}
		*/


	}

}


typedef FlumpPendingSymbolAttachment = {
	var movie:FlumpMovieSymbol;
	var keyframe:FlumpKeyframe;
	var symbolId:String;
}















