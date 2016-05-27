package;


class PixiFlumpMain{

	public static function main():Void {
		var global:Dynamic = untyped __js__("PIXI");
		global.flump = {};

		global.flump.Movie = pixi.flump.Movie;
		global.flump.Sprite = pixi.flump.Sprite;
		global.flump.Parser = pixi.flump.Parser.parse;
	}

}