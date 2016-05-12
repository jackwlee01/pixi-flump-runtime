package;


class Main{

	public static function main():Void {
		pixi.display.FlumpMovie;
		pixi.display.FlumpSprite;
		pixi.loaders.FlumpParser;

		var global:Dynamic = untyped __js__("PIXI");
		global.flump = {};

		global.flump.Movie = pixi.display.FlumpMovie;
		global.flump.Sprite = pixi.display.FlumpSprite;
		global.flump.Parser = pixi.loaders.FlumpParser.flumpParser;
	}

}