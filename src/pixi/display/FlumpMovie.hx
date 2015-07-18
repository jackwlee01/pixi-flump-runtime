package pixi.display;

import flump.FlumpLibrary;
import flump.FlumpMovieSymbol;
import flump.FlumpLayer;
import flump.FlumpKeyframe;
import pixi.core.display.Container;
import pixi.core.display.DisplayObject;



class FlumpMovie extends Container{

	private var symbol:FlumpMovieSymbol;
	private var factory:FlumpFactory;
	public var layers = new Map<String, Container>();

	private var currentlyShowing = new Map<FlumpLayer, DisplayObject>();
	private var displayObjects = new Map<FlumpKeyframe, DisplayObject>();


	public function new(symbol:FlumpMovieSymbol, factory:FlumpFactory){
		super();
		this.symbol = symbol;
		this.factory = factory;
		
		for(layer in symbol.layers){
			var layerContainer = layers[layer.name] = new Container();
			addChild(layerContainer);

			for(keyframe in layer.keyframes){
				trace(keyframe.index);
			}
		}
		renderFrame(0);
	}


	public function renderFrame(index:Float){
		for(layer in symbol.layers){
			var container = layers[layer.name];
			
			var keyframe = layer.keyframes[0];
			var i = 0;
			while(keyframe.index < index % layer.length){
				i++;
				if(i < layer.keyframes.length){
					keyframe = layer.keyframes[i];
				}else{
					break;
				}
			}
			var nextKeyframe = layer.keyframes[(i+1)%layer.keyframes.length];
			var frame = index % layer.length;

			var interped:Float = (frame - keyframe.index) / keyframe.duration;
            var ease:Float = keyframe.ease;
            if (ease != 0) {
                var t :Float;
                if (ease < 0) {
                    // Ease in
                    var inv:Float = 1 - interped;
                    t = 1 - inv * inv;
                    ease = -ease;
                } else {
                    // Ease out
                    t = interped * interped;
                }
                interped = ease * t + (1 - ease) * interped;
            }

			var displayObject:DisplayObject;
			if(displayObjects.exists(keyframe)){
				displayObject = displayObjects.get(keyframe);
				displayObject.visible = true;
			}else{
				displayObject = factory.createDisplayObject(keyframe.symbol.name);	
				displayObjects.set(keyframe, displayObject);
				container.addChild(displayObject);
			}

			var showing = currentlyShowing.get(layer);
			if(showing != displayObject && showing != null) showing.visible = false;
			currentlyShowing.set(layer, displayObject);
			
			displayObject.x = keyframe.location.x + (nextKeyframe.location.x - keyframe.location.x) * interped;
			displayObject.y = keyframe.location.y + (nextKeyframe.location.y - keyframe.location.y) * interped;
			
			displayObject.scale.x = keyframe.scale.x + (nextKeyframe.scale.x - keyframe.scale.x) * interped;
			displayObject.scale.y = keyframe.scale.y + (nextKeyframe.scale.y - keyframe.scale.y) * interped;
			//displayObject.skew.x = keyframe.skew.x;
			//displayObject.skew.y = keyframe.skew.y;
		}
		
	}

}
/*

public var pivot:Point;
	public var duration:Float;
	public var location:Point;
	public var index:UInt;
	public var symbol:FlumpSymbol;
	public var scale:Point;
	public var skew:Point;
	public var ease:Float;

*/
