package pixi.flump;

import pixi.core.display.DisplayObject;


interface Factory{

	public function displayClassExists(id:String):Bool;
	public function getMovieClass(id:String):Class<Movie>;
	public function getSpriteClass(id:String):Class<Sprite>;

}