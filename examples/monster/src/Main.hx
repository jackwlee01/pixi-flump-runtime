package;
	
import flump.library.FlumpLibrary;
import pixi.display.FlumpMovie;
import pixi.plugins.app.Application;
import pixi.loaders.Loader;
import pixi.loaders.FlumpParser;


class Main extends Application{

	private var movies = new Array<FlumpMovie>();
	

	public static function main():Void {
		new Main();
	}


	public function new(){
		super();
		super.start();

		var loader = new Loader();
		loader.after(FlumpParser.flumpParser);
		loader.add("MonsterLibrary", "./flump-assets/library.json");
		loader.once("complete", begin);
		loader.load();
	}


	public function begin(){
		var monster = new FlumpMovie("walk");
		stage.addChild(monster);
		monster.x = 200;
		monster.y = 200;
		movies.push(monster);
	}

}