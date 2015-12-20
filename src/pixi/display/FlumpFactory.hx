package pixi.display;

import pixi.core.display.DisplayObject;
import pixi.core.sprites.Sprite;
import pixi.display.FlumpMovie;


interface FlumpFactory{

	public function displayClassExists(id:String):Bool;
	public function getMovieClass(id:String):Class<FlumpMovie>;
	public function getSpriteClass(id:String):Class<Sprite>;

}