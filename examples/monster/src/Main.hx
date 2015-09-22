package;
	
import flump.library.FlumpLibrary;
import pixi.display.FlumpFactory;
import pixi.display.FlumpMovie;
import pixi.plugins.app.Application;
import pixi.display.FlumpLibraryLoader;


class Main extends Application{

	private var movies = new Array<FlumpMovie>();
	

	public static function main():Void {
		new Main();
	}


	public function new(){
		super();
		super.start();

		FlumpLibraryLoader.load("./flump-assets").addOnce( onLibraryLoaded );	
	}


	public function onLibraryLoaded(factory:FlumpFactory){
		var monster = factory.createMovie("walk");
		stage.addChild(monster);
		monster.x = 200;
		monster.y = 200;
		movies.push(monster);
	}

}