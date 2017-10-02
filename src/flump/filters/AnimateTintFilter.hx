package flump.filters;
import pixi.core.renderers.webgl.filters.Filter;

private typedef V3 = {
	var x:Float;
	var y:Float;
	var z:Float;
}

/**
 * Filter that reproduce the behaviour of Tint in Adobe Flash/Animate
 * @author Mathieu Anthoine
 */
class AnimateTintFilter extends Filter
{
	
	public function new(pColor:UInt,pMultiplier:Float=1) 
	{
		update(pColor, pMultiplier);
		super(null,getFragmentSrc(), uniforms);
	}
	
	private function getFragmentSrc ():String {
		var lSrc:String = "";

		lSrc += "precision mediump float;varying vec2 vTextureCoord;uniform sampler2D uSampler;uniform float r;uniform float g;uniform float b;uniform float multiplier;";
		lSrc += "void main () { gl_FragColor = texture2D(uSampler, vTextureCoord);";
		lSrc += "gl_FragColor.r = (r*multiplier+gl_FragColor.r*(1.0-multiplier)) * gl_FragColor.a;";
		lSrc += "gl_FragColor.g = (g*multiplier+gl_FragColor.g*(1.0-multiplier)) * gl_FragColor.a;";
		lSrc += "gl_FragColor.b = (b*multiplier+gl_FragColor.b*(1.0-multiplier)) * gl_FragColor.a;";
		lSrc += "}";	
		
		return lSrc;
	}
	
	private function hex2v3(pColor:UInt):V3 {
		return {x:(pColor >> 16 & 0xFF) / 255,y:(pColor >> 8 & 0xFF) / 255,z: (pColor & 0xFF) / 255};
	}
	
	public function update(pColor:UInt, pMultiplier:Float = 1) : Void {		
		var lColor:V3 = hex2v3(pColor);
		uniforms = {r: {type: "1f", value: lColor.x }, g: {type: "1f", value: lColor.y }, b: {type: "1f", value: lColor.z }, multiplier: {type: "1f", value: pMultiplier}};
	}
	
}