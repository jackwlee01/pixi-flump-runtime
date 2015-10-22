package;
	
import flump.library.FlumpLibrary;
import pixi.display.FlumpFactory;
import pixi.display.FlumpMovie;
import pixi.plugins.app.Application;
import pixi.loaders.FlumpParser;
import pixi.interaction.InteractionManager;
import pixi.core.graphics.Graphics;
import pixi.loaders.Loader;


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
		loader.add("DogLibrary", "./flump-assets/dog/library.json");
		loader.once("complete", begin);
		loader.load();
	}


	public function begin(){
		var factory = FlumpFactory.get("DogLibrary");
		var movie = factory.createMovie("TestScene");
		
		movie.animationSpeed = 1;
		stage.addChild(movie);
		movies.push(movie);
		
		var dog = movie.getChildMovie("DogRunning");
		
		var placeholder = movie.getLayer("Placeholder");
		var graphics = new Graphics();
		graphics.lineColor = 0x990000;
		graphics.beginFill(0x009900);
		graphics.drawCircle(100, 100, 100);
		placeholder.addChild(graphics);
	}


}