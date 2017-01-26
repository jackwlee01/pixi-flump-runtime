package flump.filters;
import pixi.core.renderers.webgl.filters.AbstractFilter;
// pixi 4 class
//import pixi.core.renderers.webgl.filters.Filter;

private typedef Uniform = {
	var type:String;
	var value:Dynamic;
}

private typedef AnimateTint = {
	var multiplier: Uniform;
	var color : Uniform;
}

private typedef V3 = {
	var x:Float;
	var y:Float;
	var z:Float;
}

/**
 * Filter that reproduce the behaviour of Tint in Adobe Flash/Animate
 * @author Mathieu Anthoine
 */
class AnimateTintFilter extends AbstractFilter
// pixi 4 class
//class AnimateTintFilter extends Filter
{

	public var multiplier (default,null):Float;
	public var color (default, null):UInt;
	
	private var uniforms:AnimateTint;
	
	public function new(pColor:UInt,pMultiplier:Float=1) 
	{
		color = pColor;
		multiplier = pMultiplier;
		uniforms = {color: {type: "v3", value: hex2v3(color)}, multiplier: {type: "1f", value: multiplier}};
		super(null,getFragmentSrc(), uniforms);

	}
	
	private function getFragmentSrc ():String {
		var lSrc:String = "";
		lSrc += "precision mediump float;varying vec2 vTextureCoord;uniform sampler2D uSampler;uniform vec3 color;uniform float multiplier;";
		lSrc += "void main () { gl_FragColor = texture2D(uSampler, vTextureCoord);";
		lSrc += "gl_FragColor.r = (color.r*multiplier+gl_FragColor.r*(1.0-multiplier)) * gl_FragColor.a;";
		lSrc += "gl_FragColor.g = (color.g*multiplier+gl_FragColor.g*(1.0-multiplier)) * gl_FragColor.a;";
		lSrc += "gl_FragColor.b = (color.b*multiplier+gl_FragColor.b*(1.0-multiplier)) * gl_FragColor.a;";
		lSrc += "}";
		return lSrc;
	}
	
	private function hex2v3(pColor:UInt):V3 {
		return {x:(pColor >> 16 & 0xFF) / 255,y:(pColor >> 8 & 0xFF) / 255,z: (pColor & 0xFF) / 255};
	}
	
	public function update(pColor:UInt, pMultiplier:Float = 1) : Void {
		uniforms.color.value = hex2v3(color=pColor);
		//uniforms.multiplier.value = multiplier= pMultiplier;
		// this might be a related to different implement of Filter/AbtractFIlter between pixi v4 & v3 ? ; if you don't make this test, you might get a runtime type error with v4
		// this is just a patch, I 'm not used to the Tint extra feature ; this feature is not tested in v4 yet, so this patch doesn't solve this feature for v4, it just guarantees to run without code crash
		if ( ! Std.is( uniforms.multiplier, Float)) uniforms.multiplier.value = multiplier= pMultiplier;
	}
	
}