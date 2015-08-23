package;
	
import flump.library.FlumpLibrary;
import pixi.display.FlumpFactory;
import pixi.display.Movie;
import pixi.plugins.app.Application;
import pixi.display.FlumpLibraryLoader;


class Main extends Application{

	private var movies = new Array<Movie>();
	

	public static function main():Void {
		new Main();
	}


	public function new(){
		super();
		this.onUpdate = tick;
		super.start();

		FlumpLibraryLoader.load("./flump-assets/dog").addOnce( onLibraryLoaded );	
	}


	public function onLibraryLoaded(factory:FlumpFactory){
		var movie = factory.createMovie("TestScene");
		_stage.addChild(movie);
		movies.push(movie);
	}


	public function tick(time:Float){
		for(movie in movies) movie.player.advanceTime(time);
	}

}