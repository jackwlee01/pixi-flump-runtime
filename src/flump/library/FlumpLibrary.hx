package flump.library;

import flump.DisplayObjectKey;
import flump.json.FlumpJSON;
import flump.library.Label;
using Lambda;


class FlumpLibrary{

	public var movies = new Map<String, MovieSymbol>();
	public var sprites = new Map<String, SpriteSymbol>();
	public var atlases = new Array<AtlasSpec>();
	public var framerate:Float;
	public var frameTime:Float;
	public var md5:String;
	public var resolution:Float;


	function new(resolution:Float){
		this.resolution = resolution;
	}


	public static function create(flumpData:Dynamic, resolution:Float):FlumpLibrary{
		var lib:FlumpJSON = cast flumpData;
		
		var spriteSymbols = new Map<String, SpriteSymbol>();
		var movieSymbols = new Map<String, MovieSymbol>();

		var flumpLibrary = new FlumpLibrary(resolution);
		flumpLibrary.sprites = spriteSymbols;
		flumpLibrary.movies = movieSymbols;
		flumpLibrary.framerate = lib.frameRate;
		flumpLibrary.frameTime = 1000/flumpLibrary.framerate;		
		flumpLibrary.md5 = lib.md5;

		var atlasSpecs = new Array<flump.json.FlumpJSON.AtlasSpec>();
		var textureGroup = null;

		// Find best suited resolution from available textures
		for(tg in lib.textureGroups){
			if(tg.scaleFactor >= resolution && textureGroup == null) textureGroup = tg;
		}
		if(textureGroup == null) textureGroup =  lib.textureGroups[lib.textureGroups.length-1];


		for(atlas in textureGroup.atlases){
			flumpLibrary.atlases.push(atlas);
			atlasSpecs.push(atlas);
		}


		for(spec in atlasSpecs){			
			for(textureSpec in spec.textures){
				var frame = new Rectangle(textureSpec.rect.x, textureSpec.rect.y, textureSpec.rect.width, textureSpec.rect.height);
				var origin = new Point(textureSpec.origin.x, textureSpec.origin.y);
			
				var symbol = new SpriteSymbol();
				symbol.name = textureSpec.symbol;
				symbol.data = textureSpec.data;
				symbol.baseClass = textureSpec.baseClass;				
				symbol.origin = origin;
				symbol.texture = textureSpec.symbol;
				spriteSymbols[symbol.name] = symbol;
			}
		}

		var pendingSymbolAttachments = new Map<Keyframe, String>();
		for(movieSpec in lib.movies){
			var symbol = new MovieSymbol();
			symbol.name = movieSpec.id;
			symbol.data = movieSpec.data;
			symbol.baseClass = movieSpec.baseClass;
			symbol.library = flumpLibrary;
			for(layerSpec in movieSpec.layers){
				var layer = new Layer(layerSpec.name);
				layer.movie = symbol;
				layer.mask = layerSpec.mask;
				var layerDuration:Float = 0;
				var previousKeyframe:Keyframe = null;
				for(keyframeSpec in layerSpec.keyframes){
					var keyframe = new Keyframe();
					keyframe.prev = previousKeyframe;
					if(previousKeyframe != null) previousKeyframe.next = keyframe;
					keyframe.layer = layer;
					keyframe.numFrames = keyframeSpec.duration;
					keyframe.duration = keyframeSpec.duration * flumpLibrary.frameTime;
					keyframe.index = keyframeSpec.index;

					var time = keyframe.index * flumpLibrary.frameTime;
					time *= 10;
					time = Math.floor(time);
					time /= 10;
					keyframe.time = time;
					
					if(keyframeSpec.ref == null){
						keyframe.isEmpty = true;
					}else{
						keyframe.isEmpty = false;
						keyframe.symbolId = keyframeSpec.ref;
						keyframe.pivot = keyframeSpec.pivot == null ? new Point(0,0) : new Point( keyframeSpec.pivot.x * resolution, keyframeSpec.pivot.y * resolution);
						keyframe.location = keyframeSpec.loc == null ? new Point(0,0) : new Point( keyframeSpec.loc.x * resolution, keyframeSpec.loc.y * resolution);
						keyframe.tweened = keyframeSpec.tweened == false ? false : true;
						keyframe.symbol = null;
						keyframe.scale = keyframeSpec.scale == null ? new Point(1,1) : new Point(keyframeSpec.scale.x, keyframeSpec.scale.y);
						keyframe.skew = keyframeSpec.skew == null ? new Point(0,0) : new Point(keyframeSpec.skew.x, keyframeSpec.skew.y);
						keyframe.alpha = keyframeSpec.alpha == null ? 1 : keyframeSpec.alpha;
						keyframe.tintMultiplier = keyframeSpec.tint == null ? 0 : keyframeSpec.tint[0];
						keyframe.tintColor = keyframeSpec.tint == null ? 0 : Std.parseInt(StringTools.replace(cast(keyframeSpec.tint[1], String), "#", "0x"));
						keyframe.data = keyframeSpec.data;
						
						keyframe.ease = keyframeSpec.ease == null ? 0 : keyframeSpec.ease;	
					}

					if(layer.keyframes.length == 0) layer.firstKeyframe = keyframe;

					if(keyframeSpec.label != null){
						keyframe.label = new Label();
						keyframe.label.keyframe = keyframe;
						keyframe.label.name = keyframeSpec.label;
						symbol.labels.set(keyframe.label.name, keyframe.label);
					}
					
					if(keyframe.time + keyframe.duration > layer.duration){
						layerDuration = keyframe.time + keyframe.duration;
					}

					pendingSymbolAttachments[keyframe] = keyframeSpec.ref;
					layer.keyframes.push(keyframe);
					previousKeyframe = keyframe;
				}

				layer.lastKeyframe = layer.keyframes[layer.keyframes.length - 1];
				layer.keyframes[0].prev = layer.lastKeyframe;
				layer.lastKeyframe.next = layer.keyframes[0];
				symbol.layers.push(layer);

				var allAreEmpty = layer.keyframes.foreach(function(keyframe) return keyframe.isEmpty);

				if(allAreEmpty){
					
				}else{
					for(keyframe in layer.keyframes){
						var hasNonEmptySibling = layer.keyframes.exists(function(checkedKeyframe) return checkedKeyframe.isEmpty == false && checkedKeyframe != keyframe);
						if(hasNonEmptySibling){
							var checked = keyframe.prev;
							while(checked.isEmpty) checked = checked.prev;
							keyframe.prevNonEmptyKeyframe = checked;

							checked = keyframe.next;
							while(checked.isEmpty) checked = checked.next;
							keyframe.nextNonEmptyKeyframe = checked;
						}else{
							keyframe.prevNonEmptyKeyframe = keyframe;
							keyframe.nextNonEmptyKeyframe = keyframe;
						}
					}

					// Set up diplay keys
					var firstNonEmpty = layer.keyframes.find(function(checkedKeyframe) return checkedKeyframe.isEmpty == false);
					if(firstNonEmpty != null) firstNonEmpty.displayKey = new DisplayObjectKey(firstNonEmpty.symbolId);
					var checked = firstNonEmpty.nextNonEmptyKeyframe;
					while(checked != firstNonEmpty){
						if(checked.symbolId == checked.prevNonEmptyKeyframe.symbolId) checked.displayKey = checked.prevNonEmptyKeyframe.displayKey;
						else checked.displayKey = new DisplayObjectKey(checked.symbolId);
						checked = checked.nextNonEmptyKeyframe;
					}
				}		
			}

			function getHighestFrameNumber(layer:Layer, accum:UInt){
				var layerLength = layer.lastKeyframe.index + layer.lastKeyframe.numFrames;
				return layerLength > accum
					? layerLength
					: accum;
			}

			symbol.totalFrames = symbol.layers.fold( getHighestFrameNumber, 0 );
			symbol.duration = symbol.totalFrames * flumpLibrary.frameTime;

			var labels = new Array<Label>();
			for(layer in symbol.layers){
				for(keyframe in layer.keyframes){
					if(keyframe.label != null){
						labels.push(keyframe.label);
					}
				}
			}
			haxe.ds.ArraySort.sort(labels, sortLabel);
			for(i in 0...labels.length){
				var nextIndex = i+1;
				if(nextIndex >= labels.length) nextIndex = 0;

				var label = labels[i];
				var nextLabel = labels[nextIndex];
				label.next = nextLabel;
				nextLabel.prev = label;
			}
			symbol.firstLabel = labels[0];
			symbol.lastLabel = labels[labels.length-1];
			
			movieSymbols[symbol.name] = symbol;			
		}

		for(keyframe in pendingSymbolAttachments.keys()){
			var symbolId = pendingSymbolAttachments[keyframe];
			keyframe.symbol = spriteSymbols[symbolId] != null ? spriteSymbols[symbolId] : movieSymbols[symbolId];
		}

		return flumpLibrary;
	}


	private static function sortLabel(a:Label, b:Label):Int{
		if(a.keyframe.index < b.keyframe.index) return -1;
		else if(a.keyframe.index > b.keyframe.index) return 1;
		return 0;
	}



}