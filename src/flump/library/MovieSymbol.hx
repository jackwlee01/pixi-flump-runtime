package flump.library;

import flump.library.FlumpLibrary;


class MovieSymbol extends Symbol{

	public var layers = new Array<Layer>();
	public var labels = new Map<String, Label>();
	public var library:FlumpLibrary;

	public var duration:Float;
	public var totalFrames:UInt;
	public var firstLabel:Label;
	public var lastLabel:Label;


	public function new(){
		super();
	}


	public function getLayer(name:String):Layer{
		for(layer in layers) if(layer.name == name) return layer;
		return null;
	}


	public function debug(){
		var largestLayerChars = Lambda.fold(layers, function(layer, result) return layer.name.length > result ? layer.name.length : result, 0);

		function repeat(character, amount){
			var output = "";
			while(amount > 0){
				output += character;
				amount--;
			}
			return output;
		}

		//◙◉◉◉◙◙○◌◌◌◙▸▸▸◙○◌◌
		var output = "asdfsadf\n";

		output += repeat(" ", largestLayerChars);	
		output += "   ";
		for(i in 0...totalFrames){
			if(i%5 == 0) output += i;
			else{
				if(i % 6 != 0 || i < 10) output += " ";
			}
		}
		output += "\n";

		output += repeat(" ", largestLayerChars);	
		output += "   ";
		for(i in 0...totalFrames){
			if(i%5 == 0) output += "▽";
			else output += " ";
		}
		output += "\n";


		for(i in 0...layers.length){
			var layer = layers[i];

			output += layer.name + repeat(" ", largestLayerChars-layer.name.length); 
			output += " : ";
			for(keyframe in layer.keyframes){
				if(keyframe.symbolId != null){
					output += "◙";
					if(keyframe.tweened) output += repeat("▸", keyframe.numFrames-1);
					else output += repeat("◉", keyframe.numFrames-1) ;
				}else{
					output += "○";
					output += repeat("◌", keyframe.numFrames-1);
				}
			}
			output += '\n';
		}

		return output;

	}

}