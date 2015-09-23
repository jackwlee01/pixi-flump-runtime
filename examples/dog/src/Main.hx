package;
	
import flump.library.FlumpLibrary;
import pixi.display.FlumpFactory;
import pixi.display.FlumpMovie;
import pixi.plugins.app.Application;
import pixi.display.FlumpLibraryLoader;
import pixi.interaction.InteractionManager;
import pixi.core.graphics.Graphics;


class Main extends Application{

	private var movies = new Array<FlumpMovie>();
	private var pos:Int = 0;


	public static function main():Void {
		new Main();
	}


	public function new(){
		super();
		super.start();

		FlumpLibraryLoader.load("./flump-assets/dog").addOnce( onLibraryLoaded );	

		js.Browser.document.onmousemove = function(e){
			pos = e.pageX*3;
		}
	}


	public function onLibraryLoaded(factory:FlumpFactory){
		var movie = factory.createMovie("TestScene");
		stage.addChild(movie);
		movies.push(movie);
		movie.player.loop();

		var placeholder = movie.getLayer("Placeholder");
		var graphics = new Graphics();
		graphics.lineColor = 0x990000;
		graphics.beginFill(0x009900);
		graphics.drawCircle(100, 100, 100);
		placeholder.addChild(graphics);
		
	}


}